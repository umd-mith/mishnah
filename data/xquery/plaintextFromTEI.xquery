declare namespace saxon = "http://saxon.sf.net/";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace my = "http://local-functions.uri";
declare option saxon:output "indent=yes";
declare option saxon:output "method=xml";

declare variable $wds :=
for $w in doc("../tei/t/t-temp/P00005-0105.xml")//tei:w
return
   $w;


(:declare function my:iterate($nodes)
{
   for $i in $nodes
   where $i/text() = 'רבי'
   return
      ($i)
};

my:iterate($wds) :)


declare function my:iterate($nodes)
{
   for $i in $nodes
   return
      
      if (matches($i, 'רבי'))
      then
         <pop>{$i | $i/following-sibling::tei:w[contains(., 'אומ')][1]/preceding-sibling::tei:w intersect $i/following-sibling::tei:w}</pop>
      else
         if (count($i | $i/preceding-sibling::tei:w[contains(., 'רבי')][1]/following-sibling::element() intersect $i/following-sibling::tei:w[contains(., 'אומ')][1]/preceding-sibling::element()) < 3)
         then
            ()
         else
            $i
};



my:iterate($wds)