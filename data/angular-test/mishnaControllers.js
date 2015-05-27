var mishnaApp = angular.module('mishnaApp', []);

mishnaApp.controller('MishnaCtrl', function ($scope, $http) {

$http.get('sampleJson.json').success(function(data) {
    $scope.witnesses = data.witnesses;
    $scope.rawColumnData = data.table;
	$scope.pivotedTable = [];
	
	for( j=0; j<$scope.witnesses.length; j++ ){
		$scope.witnesses[j] = $scope.witnesses[j].replace(".xml", "" );
		
		$scope.pivotedTable[$scope.witnesses[j]] = [];
		for( i=0; i<$scope.rawColumnData.length; i++ ){
			//if( $scope.rawColumnData[i][j].length != 0 )
				$scope.pivotedTable[$scope.witnesses[j]][i] = $scope.rawColumnData[i][j];
			//else
			//	$scope.pivotedTable[$scope.witnesses[j]][i] = [{"t":"-"}];
		}
	}
  });	
  
});