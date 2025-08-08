window.onload = function() {
    var board1 = JXG.JSXGraph.initBoard('board1', {
        boundingbox: [-1, 1, 1, -1],
        axis: true,
        grid: false
    });
    var board2 = JXG.JSXGraph.initBoard('board2', {
        boundingbox: [-2, 2, 2, -2],
        axis: true
    });

    var circle = board1.create('circle', [[0, 0], 1], {fixed: true, dash:1});
    
    var threeVelocity = board1.create('point', [0, 0], {
        name: '3-velocity',
        withLabel: true,
        draggable: true
    });
    
    threeVelocity.on('drag', function() {
        updateThreeVelocity();
        board2.update();
    });

    function updateThreeVelocity() {
        var x = threeVelocity.X();
        var y = threeVelocity.Y();
        var rSquared = x * x + y * y;
        if (rSquared > 0.99 * 0.99) {
            var r = Math.sqrt(rSquared);
            threeVelocity.moveTo([x / r * 0.99, y / r * 0.99]);
        }
        threeVelocity.moveTo([threeVelocity.X(), 0]); // 1D case
    };

    var fourVelocity = board2.create('point', [
        function(){ return computeFourVelocity(threeVelocity.X(), threeVelocity.Y())[0]},
        function(){ return computeFourVelocity(threeVelocity.X(), threeVelocity.Y())[1]}
    ], {
        name: '4-velocity',
        withLabel: true,
        fixed: true,
        color: '#17063A'
    });
    var fourVelocityNegative = board2.create('point', [
        function() {return -fourVelocity.X();}, 
        function() {return -fourVelocity.Y();}
    ], {
        withLabel: false,
        fixed: true,
        color: '#17063A'
    });
    
    // Function to update dot2 position based on dot1
    function computeFourVelocity(vx, vy) {
        let v = Math.sqrt(vx*vx + vy*vy);
        v = vx; // 1D case
        let u = v / Math.sqrt(1 - v*v);
        let ut = 1 / Math.sqrt(1 - v*v);
        return [u, ut];
    };

    // asymptotic lines
    var linePositive = board2.create('line', [[0, 0], [1, 1]], {straightFirst:true, straightLast:true, strokeWidth:1, dash:1});
    var lineNegative = board2.create('line', [[0, 0], [-1, 1]], {straightFirst:true, straightLast:true, strokeWidth:1, dash:1});
    // space-like hyperbolas
    board2.create('functiongraph', [function(x){ return Math.sqrt(x*x + 1); }]);
    board2.create('functiongraph', [function(x){ return -Math.sqrt(x*x + 1); }]);

    board2.create('line', [fourVelocity, fourVelocityNegative], {straightFirst: false, straightLast: false, strokeWidth: 2});

    // unit space-like vector
    var unitSpacePositive = board2.create('reflection', [fourVelocity, linePositive], {withLabel: false,color:'#17063A'});
    var unitSpaceNegative = board2.create('reflection', [fourVelocity, lineNegative], {withLabel: false,color:'#17063A'});
    board2.create('line', [unitSpaceNegative, unitSpacePositive], 
        {straightFirst: false, straightLast: false, strokeWidth: 2, color:'#17063A'});

    // Positive light cone
    var positiveConePoint1 = board2.create('point', [function(){
        return fourVelocityNegative.X() - 10 - fourVelocity.Y();
    }, 10], {withLabel: false,visible: false});
    var positiveConePoint2 = board2.create('point', [function(){
        return fourVelocityNegative.X() + 10 + fourVelocity.Y();
    }, 10], {withLabel: false,visible: false});
    var positiveCone = board2.create('polygon', [fourVelocityNegative, positiveConePoint1, positiveConePoint2], {
        fillColor: '#8b7aae',
        fillOpacity: 0.5,
        borders: {strokeWidth: 0}
    });

    // Negative light cone
    var negativeConePoint1 = board2.create('point', [function(){
        return fourVelocity.X() + 10 + fourVelocity.Y();
    }, -10], {withLabel: false,visible: false});
    var negativeConePoint2 = board2.create('point', [function(){
        return fourVelocity.X() - 10 - fourVelocity.Y();
    }, -10], {withLabel: false,visible: false});
    var negativeCone = board2.create('polygon', [fourVelocity, negativeConePoint1, negativeConePoint2], {
        fillColor: '#8b7aae',
        fillOpacity: 0.5,
        borders: {strokeWidth: 0}
    });
};
