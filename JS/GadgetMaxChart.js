var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        if (typeof b !== "function" && b !== null)
            throw new TypeError("Class extends value " + String(b) + " is not a constructor or null");
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
/*************************************************************************
 * Gadget - Example 9
 * Creates a basic Column chart using the jqChart control available in PME.
 * Request the data from a pre-defined data reader 'HorizontalBarGadgetDataReader'
 ************************************************************************/
var GadgetMaxPerDay ;
(function (GadgetMaxPerDay) {
    var Models;
    (function (Models) {
        var models = Dashboards.Models;
        var ExampleChartGadget = /** @class */ 
        (function (_super) 
        {
            __extends(ExampleChartGadget, _super);
            function ExampleChartGadget(gadgetOptions) {
                
                var _this = this;
                gadgetOptions.renderer = new GadgetMaxPerDay.Views.ExampleChartRender();
                _this = _super.call(this, gadgetOptions) || this;
                // Special case where Bar/Pie settings have the wrong aggregation settings.
                models.ViewPeriodGadget.EnsureViewingPeriodCorrectForType(_this, Settings.ViewingPeriod.SettingGroup.SingleDateWithoutAggregation);
               
                return _this;
            }
            ExampleChartGadget.CreateInstance = function (gadgetOptions) {
                
                var instance = new ExampleChartGadget(gadgetOptions);
                
                return instance;
            };
            ExampleChartGadget.hasData = function(){
                
                return  true;//this.gadget.dataSet != null
            }
            ExampleChartGadget.formatData = function(data){
                
                return data;
            }
            ExampleChartGadget.TypeId = "ed887343-c40d-4be1-8c12-c9c4d4be4806";
            return ExampleChartGadget;
        }(models.ChartingDataGadget));

        Models.ExampleChartGadget = ExampleChartGadget;

    })(Models = GadgetMaxPerDay.Models || (GadgetMaxPerDay.Models = {}));
})(GadgetMaxPerDay || (GadgetMaxPerDay = {}));


(function (_GadgetMaxPerDay) {
    var Views;
    (function (Views) {
        var views = Dashboards.Views;
        var ExampleChartRender = /** @class */ (function (_super) {
            __extends(ExampleChartRender, _super);
            function ExampleChartRender() {
                
                return _super.call(this) || this;
            }
            ExampleChartRender.prototype.destroy = function () {
                
                _super.prototype.destroy.call(this);
                this.gadget = null;
            };
            // We lean on ChartHelper (in GadgetBase.d.ts) to set consistent charting options
            ExampleChartRender.prototype.updateGadget = function (handler) {
                
                //Set the default platform chart options
                var chartOptions = views.ChartHelper.GetDefaultChartOptions(this);
                //Create a default left chart axis
                var leftAxis = views.ChartHelper.GetStandardLeftYAxis(this);
                leftAxis.location = 'left';
                chartOptions.axes = [leftAxis];
                //Create the series data for the chart from the dataset provided
                var chartSeries = [];
                var dataPoints = $.extend(true, {}, this.gadget.dataSet.ChartingData.DataPoints);
                
                _.each(this.gadget.seriesMap, function (series) {
                    // Update the dataPoints "time value" from "All Data" -> ''
                    if (dataPoints && dataPoints[series.name] && dataPoints[series.name].length > 0) {
                        var seriesDataPoint = dataPoints[series.name][0];
                        seriesDataPoint[Dashboards.Models.ChartingDataGadget.AxisLabelIdx] = '';
                    }
                    // Create a new jqChart control series
                    var jqSeries = {
                        title: series.title,
                        type: 'line',
                        strokeStyle: series.color,
                        fillStyle: series.color,
                        lineWidth: 3,
                        markers: null,
                        showInScene: true,
                        data: dataPoints[series.name]
                        
                    };
                    chartSeries.splice(0, 0, jqSeries);
                });
                chartOptions.series = chartSeries;
                var leftAxis = chartOptions.axes[0];
                leftAxis.visibleMinimum = null;
                // Create the chart
                var existingSeries = this.$getChart().jqChart('option', 'series');
                views.ChartHelper.UpdateSeriesVisibility(chartSeries, existingSeries);
                // Destroy any previous chart instance
                this.destroyChart();
                // Use the chart helper to build a consistent axis look
                views.ChartHelper.BindChartAxisLabelFormat(this, ['left']);
                this.$getChart().jqChart(chartOptions);
                // Use the chart helper to build a consistent tooltip
                views.ChartHelper.BindSimpleToolTipFormat(this);
            };
            
            return ExampleChartRender;

        }(views.ViewPeriodChartRender));

        Views.ExampleChartRender = ExampleChartRender;

    })(Views = _GadgetMaxPerDay.Views || (_GadgetMaxPerDay.Views = {}));

})(GadgetMaxPerDay || (GadgetMaxPerDay = {}));

// Register the gadget type
Dashboards.Controllers.GadgetType.RegisterDefinition({
    typeId: GadgetMaxPerDay.Models.ExampleChartGadget.TypeId,
    create: GadgetMaxPerDay.Models.ExampleChartGadget.CreateInstance,
    resourceSet: 'Gadgets'
});
