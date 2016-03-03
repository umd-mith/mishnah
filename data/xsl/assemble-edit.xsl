<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:its="http://www.w3.org/2005/11/its" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xd xs its my tei" version="2.0"
    xmlns:my="local-functions.uri">
    <xsl:output method="html" encoding="UTF-8"/>
    <xsl:param name="mcite"/>
    <xsl:param name="tractName"/>
    <xsl:param name="unit"/>
    <!-- Assembles the parts of the "edit" module of the demo -->

    <xsl:template match="/" xmlns="http://www.w3.org/1999/xhtml">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tempDiv">

        <div class="about" stye="clear:both" style="width:60%;direction:ltr"
            xmlns="http://www.w3.org/1999/xhtml" title="Digital Mishnah Project: Edit Collations">
            <h2>Edit Collations <span class="tractate">
                    <xsl:value-of select="replace($tractName,'_',' ')"/>
                </span>
                <xsl:analyze-string select="$mcite" regex="\d\.\d\.(.*)">
                    <xsl:matching-substring>
                        <xsl:text> </xsl:text><xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </h2>
            <div id="shown">
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">About this Page</a>
                </p>
            </div>
            <div id="hidden" style="display:none;">
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
                <p>To be added.</p>
                <p>
                    <a class="toggle" href="javascript:toggle('hidden')">Hide Description</a>
                </p>
            </div>

        </div>
        <xsl:copy-of select="*[local-name()= 'div'][@class = 'dropdown']"/>
        
        <xsl:choose>
            <xsl:when test="$mcite = ''">
                <div class="output-container">
                    <h3 xmlns="http://www.w3.org/1999/xhtml"><a name="alignment">&#160;</a>Output Will Display Here&#xA0;<span
                        class="link"><a href="#top">[top]</a></span></h3>
                    <p style="text-align:center;">Select Mishnah from the Panel Above</p>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div ng-app="mishnaApp" ng-controller="MishnaCtrl" class="output-container" data-mcite="{$mcite}">
                    
                    <script type="text/ng-template" id="editTemplate">
                        <div class="ngdialog-message">
                            <p ng-show="!ngDialogData.orig">Enter new/additional token.</p>
                            <p>To edit enter correction and click 'Edit'.</p>
                            <p ng-show="ngDialogData.orig">Click 'Delete' to delete token.</p>
                            <p>Click 'Cancel' to do nothing.</p>
                            
                            <input type="text" name="token"  ng-model="ngDialogData.editToken"></input>
                            <p ng-show="ngDialogData.corrected">Original text: {{ngDialogData.orig}} </p>
                            
                            <div class="ngdialog-buttons">
                                <button type="button" class="ngdialog-button ngdialog-button-primary" ng-click="closeThisDialog( ngDialogData.editToken )">Edit</button>
                                <button ng-show="ngDialogData.corrected" type="button" class="ngdialog-button ngdialog-button-primary" ng-click="closeThisDialog('undoEdit')">Undo Edits</button>
                                <button ng-show="ngDialogData.orig" type="button" class="ngdialog-button ngdialog-button-primary" ng-click="closeThisDialog('delete')">Delete</button>
                                <button type="button" class="ngdialog-button ngdialog-button-secondary" ng-click="closeThisDialog('cancel')">Cancel</button>
                            </div>
                        </div>
                    </script>
                    
                    <script type="text/ng-template" id="regroupingTemplate">
                        <div class="ngdialog-message">
                            <p>Drag tokens from one row to another to change groupings.</p>
                            <p>Click 'Add New Group' button to create another/new grouping.</p>
                            <div class="regrouping-table" dir="rtl">
                                <table id="regroupingTable">
                                    
                                    <tbody> 
                                        <tr ng-repeat="group in columnData" 
                                            ui-on-Drop="onDrop($event,$data,group)"  ng-model="columnData">
                                            <td ng-style="{{background: colorByGroup($index, token)}}"  
                                                ui-draggable="true" drag="token" 
                                                on-drop-success="dropSuccessHandler($event,$index,group)"
                                                
                                                ng-repeat="token in group track by $index" id="{{{{token[0].id}}}}" ng-click="">
                                                <div ng-repeat="subtoken in token | filter : {{$:hideShowDeleted}}"  class="rdg" id="{{{{subtoken.id + '.d'}}}}" 
                                                    >
                                                    <span class="{{{{subtoken.c || subtoken.id.match('deleted') ? 'corr-show' : 'orig-show'}}}}" id="{{{{subtoken.id + '.s'}}}}" 
                                                        ng-click="spanclick(subtoken);$event.stopPropagation()">{{subtoken.c ? subtoken.c : subtoken.t}}</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <button id="addGroup" ng-click="addGroup()">Add New Group</button>
                            <button type="button" class="ngdialog-button ngdialog-button-primary" ng-click="closeThisDialog( changedGroups )">Put in Main Table</button>
                            <button type="button" class="ngdialog-button ngdialog-button-secondary" ng-click="closeThisDialog('cancel')">Cancel</button>
                            
                        </div>
                    </script>
                    
                    
                    <div class="descr">
                        <p>Click <b>token</b> to edit</p>
                        <p>Click, hold and drag <b>token</b> to drag/drop</p>
                        <p>Click <b>column head</b> to select column for column functions</p>
                        <p>When column is highlighted, <b>click adjacent column head</b> for column merge function</p>
                        <p>When column is highlighted, <b>click column head</b> to clear highlights</p>
                    </div>
                    <div id="ctrls" class="controls">
                        <button id="addCol" ng-click="addCol()">Add Column</button>
                        <button id="delCol" ng-click="deleteColumn()">Delete Column</button>
                        <button id="group" ng-click="mergeColumns()">Merge Columns</button>
                        <button id="classify" ng-click="regroupifyColumn()">Group Readings (Selected Column)</button>
                        <button id="classify" ng-click="regroupifyDialog()">Re-Group Readings (Selected Column)</button>
                    </div>
                    <div class="descr">
                        <button id="addCol" ng-click="saveAs()">Save (to file)</button>
                        <button id="addCol" ng-click="groupifyAllCols()">Group Readings (All columns)</button>
                        <button id="addCol" ng-click="undo()">Undo</button>
                        <button id="addCol" ng-click="showDeletes()">{{showHide}} Deletes</button>
                    </div>
                    <div class="alignment-table" dir="rtl">
                        <table id="witnessesTable">
                            <thead>
                                <tr>
                                    <th id="align-pos-0">0</th>
                                    <th ng-repeat="column in pivotedTable[witnesses[0]]" ng-init="elemId='align-pos-'+ ($index+1)" ng-click="colClick( elemId, ($index ) )"
                                        id="{{{{elemId}}}}"  ng-class="{{selected: selectedCols[($index)]}}">{{$index+1}}</th>
                                </tr>
                            </thead>
                            <tbody> 
                                
                                <tr ng-repeat="witness in witnesses" 
                                    ui-on-Drop="onDrop($event,$data,pivotedTable[witness])" drop-channel="{{{{witness}}}}" ng-model="pivotedTable[witness]">
                                    <td class="wit">{{witness}}</td>
                                    <td ng-class="{{selected: selectedCols[($index)]}}" ng-style="selectedCols[($index)] ?{{}}: {{background: colorByGroup($index, token)}}"  ng-repeat="token in pivotedTable[witness] track by $index" id="{{{{token[0].id}}}}" ng-click="divclick(witness, $index)">
                                        <div ng-repeat="subtoken in token | filter : {{$:hideShowDeleted}} track by $index"  class="rdg" id="{{{{subtoken.id + '.d'}}}}" 
                                            ui-draggable="true" drag="subtoken" drag-channel="{{{{witness}}}}" 
                                            on-drop-success="dropSuccessHandler($event,$index,pivotedTable[witness])">
                                            <span class="{{{{subtoken.c || subtoken.id.match('deleted') ? 'corr-show' : 'orig-show'}}}}" id="{{{{subtoken.id + '.s'}}}}" ng-click="spanclick(subtoken);$event.stopPropagation()">{{subtoken.c ? subtoken.c : subtoken.t}}</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
</xsl:stylesheet>
