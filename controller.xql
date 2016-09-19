xquery version "3.0";

declare namespace json="http://www.json.org";

(:import module namespace console="http://exist-db.org/xquery/console";:)

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

(: Determine if the persistent login module is available :)
declare variable $login :=
    let $tryImport :=
        try {
            util:import-module(xs:anyURI("http://exist-db.org/xquery/login"), "login", xs:anyURI("resource:org/exist/xquery/modules/persistentlogin/login.xql")),
            true()
        } catch * {
            false()
        }
    return
        if ($tryImport) then
            function-lookup(xs:QName("login:set-user"), 3)
        else
            local:fallback-login#3
;
 
(:~
    Fallback login function used when the persistent login module is not available.
    Stores user/password in the HTTP session.
 :)
declare function local:fallback-login($domain as xs:string, $maxAge as xs:dayTimeDuration?, $asDba as xs:boolean) {
    let $durationParam := request:get-parameter("duration", ())
    let $user := request:get-parameter("user", ())
    let $password := request:get-parameter("password", ())
    let $logout := request:get-parameter("logout", ())
    return
        if ($durationParam) then
            error(xs:QName("login"), "Persistent login module not enabled in this version of eXist-db")
        else if ($logout) then
            session:invalidate()
        else 
            if ($user) then
                let $isLoggedIn := xmldb:login("/db", $user, $password, true())
                return
                    if ($isLoggedIn and (not($asDba) or xmldb:is-admin-user($user))) then (
                        session:set-attribute("digitalmishnah.user", $user),
                        session:set-attribute("digitalmishnah.password", $password),
                        request:set-attribute($domain || ".user", $user),
                        request:set-attribute("xquery.user", $user),
                        request:set-attribute("xquery.password", $password)
                    ) else
                        ()
            else
                let $user := session:get-attribute("digitalmishnah.user")
                let $password := session:get-attribute("digitalmishnah.password")
                return (
                    request:set-attribute($domain || ".user", $user),
                    request:set-attribute("xquery.user", $user),
                    request:set-attribute("xquery.password", $password)
                )
};

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/" or $exist:path eq "/index.html") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/templates/index.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
    
else if ($exist:resource = '$app-root') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat(request:get-context-path(), '/', request:get-attribute("$exist:prefix"), '/', request:get-attribute('$exist:controller'))}"/>
    </dispatch>


else if (contains($exist:path, '$app-root')) then 
    (: redirect to resources actual location :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
         <forward url="{concat($exist:controller, '/', substring-after($exist:path, '/$app-root/'))}"/>
    </dispatch>

else if ($exist:path eq "/login") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/templates/login.html"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>

else if ($exist:path eq "/edit") then (
    let $loggedIn := $login("org.exist.login", (), false())
    let $user := request:get-attribute("org.exist.login.user")
    return
        if ($user) then 
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <forward url="{$exist:controller}/templates/edit.html"/>
                <view>
                <forward url="{$exist:controller}/modules/view.xql"> 
                    <set-attribute name="resource" value="edit"/>
                </forward>
                </view>
            </dispatch>
        else
            <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                <redirect url="{concat(request:get-context-path(), '/', request:get-attribute("$exist:prefix"), '/', request:get-attribute('$exist:controller'))}/login"/>
            </dispatch>
)

else if ($exist:path eq "/align") then
      <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
          <forward url="{$exist:controller}/templates/align.html"/>
          <view>
              <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="resource" value="align"/>
              </forward>
          </view>
      </dispatch>

(:
 : List browsable witnesses
 :)
else if ($exist:path eq "/browse") then
      <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
          <forward url="{$exist:controller}/templates/browse.html"/>
          <view>
              <forward url="{$exist:controller}/modules/view.xql"/>
          </view>
      </dispatch>
      
(:
 : Display witness
 :)
else if (matches($exist:path, "/browse/[^/]+/[^/]+/[^/]+")) then
      <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
          <forward url="{$exist:controller}/templates/read.html"/>
          <view>
              <forward url="{$exist:controller}/modules/view.xql">
                <set-attribute name="resource" value="read"/>
                <set-attribute name="path" value="{$exist:path}"/>
              </forward>
          </view>
      </dispatch>
      
(:
 : Digital apparatus criticus
 :)
else if ($exist:path eq "/compare") then
      <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
          <forward url="{$exist:controller}/templates/compare.html"/>
          <view>
              <forward url="{$exist:controller}/modules/view.xql"> 
                  <set-attribute name="resource" value="compare"/>
               </forward>
          </view>
      </dispatch>
      
(:
 : Digital apparatus criticus - view
 :)
else if (matches($exist:path, "/compare/\d+\.\d+\.\d+(\.\d+)?/(\w+,?)+/(align|apparatus|synopsis)")) then
      <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
          <forward url="{$exist:controller}/templates/compareView.html"/>
          <view>
              <forward url="{$exist:controller}/modules/view.xql"> 
                  <set-attribute name="resource" value="compare"/>
                  <set-attribute name="path" value="{$exist:path}"/>
               </forward>
          </view>
      </dispatch>

(:
 : Login a user via AJAX. Just returns a 401 if login fails.
 :)
else if ($exist:resource = 'dologin') then
    let $loggedIn := $login("org.exist.login", (), false())
    let $user := request:get-attribute("org.exist.login.user")
    return
        try {
        (
            util:declare-option("exist:serialize", "method=json media-type=application/json"),
            if ($user) then
                <status>
                    <user>{request:get-attribute("org.exist.login.user")}</user>
                    <isAdmin json:literal="true">{ xmldb:is-admin-user((request:get-attribute("org.exist.login.user"),request:get-attribute("xquery.user"), 'nobody')[1]) }</isAdmin>
                </status>
            else (
                response:set-status-code(401),
                <status>fail</status>
            )
            )
        } catch * {
            response:set-status-code(401),
            <status>{$err:description}</status>
        }

(:else if (ends-with($exist:resource, ".html")) then
    (\: the html page is run through view.xql to expand templates :\)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/templates/{$exist:resource}"/>
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>:)
    
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
