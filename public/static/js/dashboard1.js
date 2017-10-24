$.ajax({
    url: "/api/v1/peptide/length/17",
    type: 'GET',
    dataType: 'json',
    success: function(data) { renderCanvas(data) },
});

function renderCanvas(data) {
    var payload = [];

    var count = 0;
    for (let d of data) {
        count++;

        var coords = {
            y: d.predicted_time,
            x: d.bullbreese
        };
    }

    var chart = new CanvasJS.Chart("morris-area-chart",
        {
            animationEnabled: true,
            zoomEnabled: true,
          
            title: {
                text: count + " total peptides"
            },    
            data: [
                {
                    type: "line",              
                    dataPoints: payload
                }
            ]
        }
    );

    chart.render();
}

$('.vcarousel').carousel({ interval: 3000 });
