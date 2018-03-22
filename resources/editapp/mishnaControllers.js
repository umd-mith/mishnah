// This code developed by Alan Gersh for digitalmishnah.
// Minor adjustments by Raff Viglianti for integration into main site.

var mishnaApp = angular.module('mishnaApp', ['ang-drag-drop','ngDialog'] );

mishnaApp.controller('RegroupingCtrl', function ($scope, ngDialog ){
	$scope.columnData = $scope.ngDialogData.columnData;
	$scope.changedGroups = [];
	
	$scope.onDrop = function($event,$data,array){
		//  $scope.undoPush();
		$data.forEach(function(tok){
			tok.group = array[0][0].group;
			});
		array.push( $data );
		$scope.changedGroups.push( $data );
	};
	
	$scope.dropSuccessHandler = function($event,index,array){
			array.splice( index, 1 );
	};
	
	$scope.addGroup = function(){
		$scope.columnData.push( [[]]);
		$scope.columnData[ $scope.columnData.length-1 ][0].group = $scope.columnData.length;
	};
});

mishnaApp.controller('MishnaCtrl', function ($scope, ngDialog, $http) {

//var mcite = $('div[ng-controller=MishnaCtrl]').data('mcite');
var m = "4.1.1.1";
/*var data_loc = 'modules/getMishnahTksJSON.xql?mcite=';*/
var data_loc = 'modules/w-sep-to-json.xql?wits=all&mcite=';

var render = function (mcite) {

$scope.mcite = mcite;

$http.get(data_loc+mcite, { params: { 'foobar': new Date().getTime() } })
    .success(function(pre_data) {
		
    console.log(JSON.stringify(pre_data))
		
    $http({
        method: 'POST',
        url: 'http://54.152.68.192/collatex/collate',
        data: pre_data,
        headers: {
        	'Accept': 'application/json',
        	'Content-Type': 'application/json'}
    })
    .success(function(data) {
    
        // reorder data according to pre_data
        
        var witnesses = []
    
        for (i=0; i<pre_data.witnesses.length; i++) {
            witnesses.push(pre_data.witnesses[i].id)
        }
    
//        console.log(JSON.stringify(data))
        $scope.witnesses = witnesses;
        $scope.originalWitnesses = data.witnesses;
        $scope.rawColumnData = data.table;
    	$scope.pivotedTable = {};
    
    	$scope.hideShowDeleted = "!deleted";
    	$scope.showHide = "Show ";
    	$scope.selectedCols = [];
    	$scope.editToken = "";
    	
    	$scope.showDeletes = function(){
    		if( $scope.hideShowDeleted == "" ){
    			$scope.hideShowDeleted = "!deleted";
    			$scope.showHide = "Show ";
    		} else {
    			$scope.hideShowDeleted = "";
    			$scope.showHide = "Hide ";
    		}
    	}
    	
    	
    	$scope.undoStack = [];
    	$scope.undoPush = function(){
    		var tmp = JSON.parse(JSON.stringify($scope.pivotedTable));
    		$scope.undoStack.push( tmp );
    	};
    	$scope.undo = function(){
    		if( $scope.undoStack.length > 0 )
    			$scope.pivotedTable = $scope.undoStack.pop();
    	};
    	
    	
    	for( j=0; j<$scope.witnesses.length; j++ ){
    		$scope.witnesses[j] = $scope.witnesses[j].replace(".xml", "" );
    		$scope.selectedCols[ j ] = false;
    		
    		$scope.pivotedTable[$scope.witnesses[j]] = [];
    		for( i=0; i<$scope.rawColumnData.length; i++ ){
    				$scope.pivotedTable[$scope.witnesses[j]][i] = $scope.rawColumnData[i][j];
    		}
    	}
     
     
    	$scope.unpivotTable = function(){
    		$scope.reversePivotedTable = [];
    		// loop through columns...
    		for( i=0; i<$scope.pivotedTable[$scope.witnesses[0]].length; i++ ){
    			// get/create classification / column ID
    			var columnId = "";
    			var j = 0;
    			while( ! columnId ){
    				if( $scope.pivotedTable[$scope.witnesses[j]][i].length > 0 && $scope.pivotedTable[$scope.witnesses[j]][i][0] )
    					columnId = $scope.pivotedTable[$scope.witnesses[j]][i][0].id;
    					j++;
    			}
    			columnId = columnId.replace( ".deleted", "" );
    			columnId = columnId.replace( "-n", "" );
    			columnId = columnId.replace( /^\w+\./, "" );
    			columnId = columnId.replace( /\d+$/, "" );
    			columnId = columnId + (i+1);
    
    			ctmp = {};
    			ctmp[columnId] = [];
    			$scope.reversePivotedTable[i] = ctmp;
    				for( j=0; j<$scope.witnesses.length; j++ ){
    					$scope.reversePivotedTable[i][columnId][j] = $scope.pivotedTable[$scope.witnesses[j]][i];			}
    
    		}
    		var jsonArray = $scope.reversePivotedTable ;
    		var retval =  JSON.stringify( { "witnesses": $scope.originalWitnesses, "table": jsonArray } ) ;
    		console.log("table to be converted")
    		console.log(retval);
    		//alert( "(Testing...) JSON to be saved: " + retval );    
//    		console.log(retval)
    		return toTEIXML({ "witnesses": $scope.originalWitnesses, "table": jsonArray });;
    	};
    	
    	function combine( token ){
    		var combined = "";
    		token.forEach( function( subtok ){ 
    				if( subtok.id && ! subtok.id.match( /\.deleted/) ) 
    					combined +=( (combined!=""?" ":"")+( subtok.c ? subtok.c : subtok.t )) 
    				} );
    		return combined;
    	};
    	
    	$scope.groupifyColumn = function( col ){    	   
    		var groups = [];
    		for( j=0; j<$scope.witnesses.length; j++ ){
    			var gNum = null;
    			var combinedToken = combine( $scope.pivotedTable[$scope.witnesses[j]][col] );
    			console.log(combinedToken)
    			for( g=0; g<groups.length; g++ ){
    				if( combinedToken == groups[g] ){
    					gNum = g;
    					break;
    				}
    				else {console.log('this is different', combinedToken, groups[g])}    				
    			}

    			if( gNum == null ){
    				gNum = groups.length;
    				groups.push( combinedToken );
    			}
    //			$scope.pivotedTable[$scope.witnesses[j]][col].group = (gNum+1) ; // +1 so that group != 0 for color assignment below
    			$scope.pivotedTable[$scope.witnesses[j]][col].forEach( function(tok){tok.group = (gNum+1);}) ; // +1 so that group != 0 for color assignment below
    		}
    		console.log(groups)
    	};
    	
    	$scope.groupifyAllCols = function(){
    	console.log($scope.pivotedTable)
    		for( i=0; i<$scope.pivotedTable[$scope.witnesses[0]].length; i++ ){
    			$scope.groupifyColumn(i);
    		}
    	};
    	
    	$scope.colorByGroup = function( ndx, token ){
    		ndx = 0; // make all columns same color scheme
    		if( token[0] && token[0].group )
    			return "hsl( " + (35+(ndx%10)*36) +" , 40%, " + (100- token[0].group * 10) + "%)"; //"rgb( 0, 0, " + (255- token.group * 16) + ")";
    		else
    			return "rgb( 255, 255, 255)";
    	};
    	$scope.regroupifyColumn = function(){
    		var columnNdx = $scope.selectedCols.indexOf( true );
    		$scope.groupifyColumn(columnNdx);
    	};
    	
    	$scope.saveAs = function(){
    	           $scope.groupifyAllCols();
    		var filename = prompt( "Enter name of file to save", $scope.mcite+".xml");
    		var blob = new Blob([$scope.unpivotTable()], {type: "text/plain;charset=utf-8"});
    		saveAs( blob, filename );
    	};
    
    	function getIndexInRowForModel( item ){
    		if( item == "" )
    				return null;
    		var locItem = item.replace(".s", "").replace(".d", "" );
    		var wit = item.split('.', 1);
    
    		for( i=0; i<$scope.pivotedTable[wit].length; i++ ){
    			if( $scope.pivotedTable[wit][i] && 
    					Array.isArray( $scope.pivotedTable[wit][i] ) && $scope.pivotedTable[wit][i].length > 0 )
    				for( j=0; j<$scope.pivotedTable[wit][i].length; j++ )
    					if( $scope.pivotedTable[wit][i][j].id == locItem )
    						return i;
    		}
    		return null;
    	}
    	
    	function getIndexInCellForModel( item, cellIndex ){
    		if( item == "" )
    				return null;
    		var locItem = item.replace(".s", "").replace(".d", "" );
    		var wit = item.split('.', 1);
    
    		if( $scope.pivotedTable[wit][cellIndex] && 
    					Array.isArray( $scope.pivotedTable[wit][cellIndex] ) && $scope.pivotedTable[wit][cellIndex].length > 0 )
    				for( j=0; j<$scope.pivotedTable[wit][cellIndex].length; j++ )
    					if( $scope.pivotedTable[wit][cellIndex][j].id == locItem )
    						return j;
    		return null;
    	}
    	
    	
    	$scope.dropSuccessHandler = function($event,index,array){
    		// NB: index param is index W/IN cell/token array (of the src cell), NOT cell index in row
    		if( targetNdx != srcNdx ){
    			array[srcNdx].splice( index, 1 );
    			//if( array[srcNdx].length == 0 ) array[srcNdx].push("");
    		}
           };
      
           $scope.onDrop = function($event,$data,array){
		  $scope.undoPush();
		  
		  targetNdx = getIndexInRowForModel( $event.target.id );
		  if( targetNdx == null ) 
			  targetNdx = $event.target.cellIndex -1;
		  srcNdx = getIndexInRowForModel( $data.id );
		  
		  if( targetNdx != srcNdx ){
			array[targetNdx].push( $data );
		  } else { // else... deal w/reordering w/in a cell
			targetReorderNdx = getIndexInCellForModel( $event.target.id, targetNdx );
			// NB: possible TO-DO: if event.target is td tag & not a span -> batel! ('cuz not 100% right in such case...)
			srcReorderNdx = getIndexInCellForModel( $data.id, targetNdx);
		  	if( targetReorderNdx > srcReorderNdx ){
				array[targetNdx].splice( targetReorderNdx+1, 0, $data );
				array[targetNdx].splice( srcReorderNdx, 1);		  
			} else {
				array[targetNdx].splice( srcReorderNdx, 1);		  
				array[targetNdx].splice( targetReorderNdx, 0, $data );
			}
		  }
            };
      
                 $scope.onDrop = function($event,$data,array){
		  $scope.undoPush();
		  targetNdx = getIndexInRowForModel( $event.target.id );
		  if( targetNdx == null ) 
			  targetNdx = $event.target.cellIndex -1;
		  srcNdx = getIndexInRowForModel( $data.id );
		  
		  if( targetNdx != srcNdx ){
			array[targetNdx].push( $data );
		  } else { // else... deal w/reordering w/in a cell
			targetReorderNdx = getIndexInCellForModel( $event.target.id, targetNdx );
			// NB: possible TO-DO: if event.target is td tag & not a span -> batel! ('cuz not 100% right in such case...)
			srcReorderNdx = getIndexInCellForModel( $data.id, targetNdx);
		  	if( targetReorderNdx > srcReorderNdx ){
				array[targetNdx].splice( targetReorderNdx+1, 0, $data );
				array[targetNdx].splice( srcReorderNdx, 1);		  
			} else {
				array[targetNdx].splice( srcReorderNdx, 1);		  
				array[targetNdx].splice( targetReorderNdx, 0, $data );
			}
		  }
      };

            $scope.rowOnDrop = function($event,$data,array){
      		  $scope.undoPush();
      		  dropNdx = array.indexOf($event.target.id);
      		  array.splice( dropNdx, 0, $data );
      		};
      	  $scope.rowDropSuccessHandler = function($event,index,array){
      			array.splice( (dropNdx>index)? index : index+1, 1 );
            };
	  
	  
	    $scope.regroupifyDialog = function () {
			var columnDataNdx = $scope.selectedCols.indexOf( true );
			var morphedColumn = [];		
			var groups = [];
			for( j=0; j<$scope.witnesses.length; j++ ){
				for( g=0; g<groups.length; g++ ){
					if( $scope.pivotedTable[$scope.witnesses[j]][columnDataNdx][0] && 
						$scope.pivotedTable[$scope.witnesses[j]][columnDataNdx][0].group == groups[g] ){
						morphedColumn[g].push( $scope.pivotedTable[$scope.witnesses[j]][columnDataNdx] );
						break;
					}
				}
				if(g == groups.length && $scope.pivotedTable[$scope.witnesses[j]][columnDataNdx][0] ){
					groups.push( $scope.pivotedTable[$scope.witnesses[j]][columnDataNdx][0].group );
					morphedColumn.push( [] );
					morphedColumn[g].push( $scope.pivotedTable[$scope.witnesses[j]][columnDataNdx] );
				}
				
			}
				
	  			var dialogPromisedResults = ngDialog.open({
					template: 'regroupingTemplate',
					controller: 'RegroupingCtrl',
					controllerAs: 'MyCtrlr',
					className: 'ngdialog-theme-default',
					scope: $scope,
					data: { columnData: morphedColumn }
				});
	  
			dialogPromisedResults.closePromise.then(function (dialogData) {
				if( dialogData.value == 'cancel' ||
					dialogData.value == '$escape'||dialogData.value == '$closeButton' || dialogData.value == '$document') 
					return;
				else {
					var regroupedColumnData = dialogData.value;
					/*for( var g=0; g < regroupedColumnData.length; g++ ){
						if(regroupedColumnData[g] )
							for( var g2=0; g2 < regroupedColumnData[g].length; g2++ ){
							*/
					for( var g=0; g < regroupedColumnData.length; g++ ){
								for( j=0; j<$scope.witnesses.length; j++ ){
									if( $scope.pivotedTable[$scope.witnesses[j]][columnDataNdx][0] && regroupedColumnData[g][0] &&
										$scope.pivotedTable[$scope.witnesses[j]][columnDataNdx][0].id == regroupedColumnData[g][0].id )
											//$scope.pivotedTable[$scope.witnesses[j]][columnDataNdx].group = regroupedColumnData[g].group;
											$scope.pivotedTable[$scope.witnesses[j]][columnDataNdx].forEach( function(tok){tok.group = regroupedColumnData[g][0].group;});
								}
							
					}
				}
			});					
		};
			
		$scope.firstClick = false;
		$scope.firstWitness = "";
		$scope.firstIndex = -1;
		$scope.secondIndex = -1;
		
		$scope.shiftSelected = {};
		$scope.clearShiftHighlighting = function(){
			$scope.witnesses.forEach( function(wit){
				$scope.shiftSelected[wit] = [];
				for( i=0; i<$scope.pivotedTable[wit].length;i++)
					$scope.shiftSelected[wit][i]=0;
			});
			document.removeEventListener("click", $scope.clearShiftHighlighting);
		};
		$scope.clearShiftHighlighting();
		
		$scope.slideTokens = function (subtok, witness){
			var dialogPromisedResults = ngDialog.open({
				template: 'slideTemplate',
				className: 'ngdialog-theme-default',
				scope: $scope,
				data: { editToken: "", corrected: null, orig : "" }
				});
			
			dialogPromisedResults.closePromise.then(function (dialogData) {
				if( dialogData.value == 'cancel' ||
					dialogData.value == '$escape'||dialogData.value == '$closeButton' || dialogData.value == '$document'){
					$scope.clearShiftHighlighting();
					return;
                                                    }
				var destCol = 0;
				if( dialogData.value.match(/^\d+$/) ){
					destCol = dialogData.value * 1.0;
					if( destCol < Math.max( $scope.firstIndex, $scope.secondIndex ) &&
						destCol >= Math.min( $scope.firstIndex, $scope.secondIndex ) )
						return;
					}
				if( destCol || dialogData.value == 'slideLeft' || dialogData.value == 'slideRight' ){
					var dir = 1;
					if( dialogData.value == 'slideRight' || 
						(destCol && destCol < Math.min( $scope.firstIndex, $scope.secondIndex ) ) )  
						dir = -1;
					$scope.undoPush();
					//$scope.secondIndex = getIndexInRowForModel( subtok.id );
					var index;
					if( dir == 1 ){
						index = ($scope.secondIndex > $scope.firstIndex ? $scope.secondIndex : $scope.firstIndex );
					} else {
						index = ($scope.secondIndex > $scope.firstIndex ? $scope.firstIndex : $scope.secondIndex );
					}
					var i = index + dir;
					while( i>-1 && i<$scope.pivotedTable[witness].length && $scope.pivotedTable[witness][i].length == 0 ) 
						i += dir;
					if(destCol)
						i = destCol + dir - 1;
					if( i-dir != index ){
							for( var j=0; j<= Math.abs($scope.secondIndex - $scope.firstIndex)&&( i-dir-(j*dir) != index ); j++ ){
							if( $scope.pivotedTable[witness][i-dir-(j*dir)].length ){
								alert( "Cannot over-write token  " + $scope.pivotedTable[witness][i-dir-(j*dir)][0].t + "!");
								$scope.clearShiftHighlighting();
								return;
							}
						}
						for( var j=0; j<= Math.abs($scope.secondIndex - $scope.firstIndex); j++ ){
							$scope.pivotedTable[witness][i-dir-(j*dir)] = $scope.pivotedTable[witness][index-(j*dir)];
							$scope.pivotedTable[witness][index-(j*dir)] = [];
							// shift highlighting...
							$scope.shiftSelected[witness][i-dir-(j*dir)] = true;
							$scope.shiftSelected[witness][index-(j*dir)] = false;
						}
					}
					document.addEventListener("click", $scope.clearShiftHighlighting);
					return;
				}
			});
		};
		
	    $scope.spanclick = function (subtok, witness, $event) {
			if( $event.shiftKey ){
				if( ! $scope.firstClick ){
					$scope.firstWitness = witness;
					$scope.firstIndex = getIndexInRowForModel( subtok.id );
					$scope.shiftSelected[witness][$scope.firstIndex] = true;
				} else {
					$scope.secondIndex = getIndexInRowForModel( subtok.id );
					if( witness == $scope.firstWitness ){
						var dir = ($scope.secondIndex > $scope.firstIndex ? 1 : -1 );						
						for( var j=0; j<= Math.abs($scope.secondIndex - $scope.firstIndex); j++ )
							$scope.shiftSelected[witness][$scope.firstIndex+dir*j] = true;
						$scope.slideTokens( subtok, witness );
					}
				}
				$scope.firstClick = ! $scope.firstClick;
				return;
			}
			  // if deleted tokens shown && this one is deleted ...
			  if( $scope.hideShowDeleted == "" &&  subtok.id && subtok.id.match( /.deleted/ ) ){
				var str = confirm("Token has been deleted. Click OK to UN-delete." );
				if( str ){
					// un-delete it
					subtok.id = subtok.id.replace( ".deleted", "" );
				}
				return;
			  }
		      //var str = prompt("Enter correction. \n Submit blank form to delete token. \n Click cancel to do nothing.", (subtok.c ? subtok.c : subtok.t) );

			$scope.editToken = (subtok.c ? subtok.c : subtok.t);
			var dialogPromisedResults = ngDialog.open({
				template: 'editTemplate',
				className: 'ngdialog-theme-default',
				scope: $scope,
				data: { editToken: $scope.editToken, corrected: !!subtok.c, orig : subtok.t }
				});
			
			dialogPromisedResults.closePromise.then(function (dialogData) {
				if( dialogData.value == 'cancel' ||
					dialogData.value == '$escape'||dialogData.value == '$closeButton' || dialogData.value == '$document') 
					return;
					
				if( dialogData.value == 'slideLeft' || dialogData.value == 'slideRight' ){
					var dir = 1;
					if( dialogData.value == 'slideRight' ) 
						dir = -1;
					$scope.undoPush();
					var index = getIndexInRowForModel( subtok.id );

					var i = index + dir;
					while( i>-1 && i<$scope.pivotedTable[witness].length && $scope.pivotedTable[witness][i].length == 0 ) 
						i += dir;
					if( i-dir != index ){
						$scope.pivotedTable[witness][i-dir] = $scope.pivotedTable[witness][index];
						$scope.pivotedTable[witness][index] = [];
					}
					return;
				}
				
		    if( dialogData.value == 'undoEdit' ){
				//$scope.undoPush(); ???
				subtok.c = null;
				if( $scope.undoStack.length > 0 ){
					var wit = subtok.id.split('.', 1);
					for( i=0; i<$scope.undoStack.length; i++ ){
						for( j=0; j<$scope.undoStack[i][wit].length; j++ ){
							$scope.undoStack[i][wit][j].forEach( function( stok ){ 
								if( stok.id && stok.id == subtok.id ){
									stok.c = null;
								}
							});
						}
					}
				}
			  } else if( dialogData.value == 'delete' ){
				$scope.undoPush();
				subtok.id = subtok.id + ".deleted";
			  } else if( dialogData.value ){
			  	$scope.undoPush();
		      	subtok.c = dialogData.value; 
		      }
			});
			  
		  };
		  
	  	$scope.divclick = function ( witness, index ){
		      //var str = prompt("Enter new/additional token." );
			  var str = null;
			  var dialogPromisedResults = ngDialog.open({
				template: 'editTemplate',
				className: 'ngdialog-theme-default',
				scope: $scope,
				data: { editToken: "", corrected: null, orig : null }
				});
			
			dialogPromisedResults.closePromise.then(function (dialogData) {
				if( dialogData.value == 'cancel' ||
					dialogData.value == '$escape'||dialogData.value == '$closeButton' || dialogData.value == '$document') 
					return;

				if( dialogData.value && dialogData.value != "" ){
					$scope.undoPush();
					str = dialogData.value; 
				}

		    if( str ){	
			  	$scope.undoPush();
				var subtok = {};
				var i = index;
				while( $scope.pivotedTable[witness][i].length == 0 ) i++;
				var token = $scope.pivotedTable[witness][i];
				tmp = token[0].id.replace( /\d+$/, "" );
				
				subtok.id = tmp + (index+1) + "-n" + ($scope.pivotedTable[witness][index].length+1);
		      	subtok.n = subtok.t = subtok.c = str;
				$scope.pivotedTable[witness][index].push( subtok );
		      }
			});
		};
		  
		  
	  $scope.setHiLight = function (columnNo){
            //show column controls
            $("div.controls").show();
            //Is this collapsable into one line?
			$scope.selectedCols[columnNo] = true;
		};
		

		// adds column to left (default) of selected column
		$scope.addCol = function (){
		   var colSelected = //$("#witnessesTable").find("tr th.selected").index();
					$scope.selectedCols.indexOf( true );
		   
		   $scope.clearCol(colSelected);
		   $scope.addColumn(colSelected);
		};
	   
		// adds column to RIGHT of selected column
		// added here just for quick testing... AG, 7/19/15
		$scope.addColRight = function (){
		   var colSelected = //$("#witnessesTable").find("tr th.selected").index();
		   					$scope.selectedCols.indexOf( true );

		   $scope.clearCol(colSelected);
		   $scope.addColumn(colSelected-1);
		};

		// does actual adding of column (into model)
		$scope.addColumn = function (columnNo){
		  $scope.undoPush();
			for( i=0; i<$scope.witnesses.length; i++ ){
				$scope.pivotedTable[$scope.witnesses[i]].splice( columnNo+1, 0, [] );
			}
			$scope.selectedCols.push(false); // NB: assumes ALL current values are FALSE, so where new one is added doesn't matter
        };
	  
	  // deletes selected column IFF it is empty of tokens
	  	$scope.deleteColumn = function (){
		  $scope.undoPush();
			var columnNdx = //$("#witnessesTable").find("tr th.selected").index() - 1;
								$scope.selectedCols.indexOf( true );
			$scope.deleteColumnNdx(columnNdx);
        };
		
		$scope.deleteColumnNdx = function (columnNdx){
			for( i=0; i<$scope.witnesses.length; i++ )
				if( Array.isArray( $scope.pivotedTable[$scope.witnesses[i]][columnNdx] ) && 
					$scope.pivotedTable[$scope.witnesses[i]][columnNdx].length > 0 &&
					$scope.pivotedTable[$scope.witnesses[i]][columnNdx][0].t.length > 0 && 
						$scope.pivotedTable[$scope.witnesses[i]][columnNdx][0].t.match( /[אבגדהוזחטיכלמנסעפצקרשתץףןםa-zA-z0-9\s\.\-_\\\/]/ ) )
					return alert( "Column must be empty to be deleted" );
			$scope.clearCol(columnNdx);
			for( i=0; i<$scope.witnesses.length; i++ ){
				$scope.pivotedTable[$scope.witnesses[i]].splice( columnNdx, 1 );
			}
        };
		
		$scope.mergeColumns = function (){
		  $scope.undoPush();
			var selectedColumns = [];
/***
			$scope.selectedCols.forEach( function(val, index){ if( val ) selectedColumns.push( index );} );
			// must choose/select 2 adjacent columns
			if( !( selectedColumns.length == 2 &&
					Math.abs( selectedColumns[0] - selectedColumns[1] ) == 1) ){
				// if not valid selection for merge, but there are selections, UN-highlight them
				for( i=0; i< selectedColumns.length; i++ )
					$scope.clearCol(selectedColumns[i]);
***/
			var firstCol = null;
			var lastCol = null;
			for( i=0; i< $scope.selectedCols.length; i++ ){
				if( $scope.selectedCols[i] ){
					if( firstCol == null )
						firstCol = i;
					else if( $scope.selectedCols[i-1] )
							lastCol = i;
						else {
							for( j=firstCol; j< $scope.selectedCols.length; j++ )
								if( $scope.selectedCols[j] )
									$scope.clearCol(j);
							return alert( "Select  adjacent columns to merge" );
						}
					}
			}
			
			var columnNdx1 = firstCol; //selectedColumns[0];
			for( m=firstCol; m<lastCol; m++ ){
				var columnNdx2 = firstCol+1; //selectedColumns[1];
				for( i=0; i<$scope.witnesses.length; i++ ){
					$scope.pivotedTable[$scope.witnesses[i]][columnNdx1] = 
						$scope.pivotedTable[$scope.witnesses[i]][columnNdx1].concat( $scope.pivotedTable[$scope.witnesses[i]][columnNdx2] );
					$scope.pivotedTable[$scope.witnesses[i]][columnNdx2] = [];
				}
				$scope.clearCol(m+1);
				$scope.deleteColumnNdx(columnNdx2);
			}
			$scope.clearCol(columnNdx1);
		};
		
		// UN-highlights selected column
	    $scope.clearCol = function (columnNo){
            //hide column controls
            $("div.controls").hide();
            if (columnNo === null || columnNo == "") {
                
                //remove all highlighting
                //Is this collapsable into one line?
				$scope.selectedCols = $scope.selectedCols.map( function(){return false;} );
            } else {
                //remove highlighting of current column
				$scope.selectedCols[columnNo ] = false;
                //return this;
            };
		};
		
		$scope.countSelectedCols = function(){
			var count = 0;
			$scope.selectedCols.forEach(  function(val, index){ if( val ) count++; } );
			return count;
		};
		
	// selects & highlights a column
	$scope.colClick = function ( id, columnNo ) {
		switch (true) {
            //selected an already selected column, and more than one selected
            case $scope.selectedCols[columnNo] && $scope.countSelectedCols() > 1 :
				//do nothing
            break;
            //an already selected column, only one selected
            case $scope.selectedCols[columnNo] && $scope.countSelectedCols() == 1 :
				//clear the column highlight
				$scope.clearCol(columnNo);
            break;
            //nothing has yet been selected
            case  $scope.countSelectedCols() == 0 :
				//highlight
				$scope.setHiLight(columnNo);
            break;
            //immediately preceding or following sibling selected
            case $scope.selectedCols[columnNo+1] :
            case $scope.selectedCols[columnNo-1] :
				//highlight
				$scope.setHiLight(columnNo);
            break;
            //user previously selected other column(s); now selects non adjacent column
            case $scope.countSelectedCols() > 0 && !$scope.selectedCols[columnNo-1] && ! $scope.selectedCols[columnNo+1] :
				//clear all highlights
				$scope.clearCol("");
				//then set column highlight
				$scope.setHiLight(columnNo);
            break;
            /* default:
             */
        };
    };	
    var scrolly;
	var draggingNow = false;
	$scope.$watch('ANGULAR_DRAG_START', function(newValue, oldValue) {
		draggingNow = true;
	});
	$scope.$watch('ANGULAR_DRAG_END', function(newValue, oldValue) {
		draggingNow = false;
	});
	$scope.scrollOut = function(){
		if( !draggingNow ) return;
		
			scrolly = setInterval( function(){
				var element = document.getElementsByClassName("alignment-table")[0];
				element.scrollLeft = -100;
			},100 );
		};
	$scope.scrollIn = function(){
			clearInterval(scrolly);
	};
	});
});
}

var updateNav = function (chap) {
    // Show next/prev navigation
    $("#dm-edit-nav").show();    
    
    var cur_mishnah_nav = $("a.list-group-item[href='#"+chap+"']");        
    
    // Determine prev
    var prev_mishnah = cur_mishnah_nav.prev('a.list-group-item');
    if (prev_mishnah.length > 0) { 
        $("#dm-edit-nav a:first-child").show().attr("href", prev_mishnah.attr("href"));        
    }
    else $("#dm-edit-nav a:first-child").hide();
    
    // Determined next
    var next_mishnah= cur_mishnah_nav.next('a.list-group-item');
    if (next_mishnah.length > 0) { 
        $("#dm-edit-nav a:last-child").show().attr("href", next_mishnah.attr("href"));        
    }
    else $("#dm-edit-nav a:last-child").hide();
}

$(window).on('hashchange',function(){
    var chap = location.hash.slice(1);
    if (chap) {
        render(chap);
        updateNav(chap);
    }
});

$(window).on('load',function(){
    var chap = location.hash.slice(1);
    if (chap) {
        render(chap);
        updateNav(chap);
    }
});

});
