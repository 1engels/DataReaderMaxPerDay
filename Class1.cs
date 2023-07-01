/*************************************************************************
 * (c) 2016 Schneider Electric. All Rights Reserved.
 ************************************************************************/
using Dashboards.Data.Reader;
using Framework.Interfaces.CommonDataStructures;
using System;
using System.ComponentModel.Composition;
using System.Linq;
using Dashboards.Data.ChartData;

namespace GadgetDevelopmentKit.Examples
{
    /// <summary>
    /// Gadget data reader for Example 8 that computes the minimum,
    /// maximum, and average values for a data set based on the interval values.
    /// </summary>
    /// <remarks>
    /// Each gadget data reader must implement IGadgetDataReader, either directly
    /// or through inheritance. There are a number of base classes available to use
    /// and are recommended when accessing PME data.
    /// Each gadget class must be decorated by an export attribute as seen below.
    /// A new instance of this class is created for each gadget data request. 
    /// In ASP.NET stateless requests are a good thing. Avoid static state!
    /// </remarks>
    [Export(typeof(IGadgetDataReader))]
    public class ExampleGadgetDataReader1 : DataSeriesGadgetDataReader
    {
        /// <summary>
        /// Gadget Type identifier. 
        /// This MUST match the Type Id defined in your Gadget.js file.
        /// </summary>
        public const string GadgetTypeId = "ed887343-c40d-4be1-8c12-c9c4d4be4806"; // use your Gadget Id, in SQL statement set datareader to NULL

        public ExampleGadgetDataReader1() : base(GadgetTypeId)
        {
        }

        /// <summary>
        /// Optional override.  In this case we use it to force no aggregation.
        /// If your gagdet uses "normal" viewing period behaviour there is no need
        /// to override this method.
        /// </summary>
        /// <param name="topicId"></param>
        /// <returns></returns>
        protected override AggregationMethod GetTimeAggregationMethod(long topicId)
        {
            // Aggregation: Average, earliest, latest, maximum, minimum, none, sum
            return AggregationMethod.Maximum;
        }

        // this function is called by default for the core service, so we use it to format the data.
        protected override object PostProcessSeriesCollectionData(SeriesCollectionModelView seriesData)
        {
            GadgetData chartGadgetData = this.GetChartGadgetData(seriesData); 
            return chartGadgetData;
        }

        // Formats the data to readable object for charting.
        protected GadgetData GetChartGadgetData(SeriesCollectionModelView providerData)
        {
            GadgetResultConverter gadgetResultConverter = new GadgetResultConverter();
            gadgetResultConverter.AlignDataBasedOnLabels = this.AlignDataBasedOnLabels;
            GadgetData gadgetData = gadgetResultConverter.GetGadgetData(providerData, base.AllDataSeries);
            GadgetResultConverter.SetDateRangeDisplayStrings(gadgetData, providerData);
            gadgetData.DateRangeString = this.GetViewingPeriodDisplayText();
            return gadgetData;
        }

        protected virtual bool AlignDataBasedOnLabels
        {
            get
            {
                return this.GetDataGrouping() == Grouping.ByInterval;
            }
        }
        /// <summary>
        /// Optional override. In this case we use it to ensure we get all data.
        /// If your gagdet uses "normal" viewing period behaviour there is no need
        /// to override this method.
        /// </summary>
        /// <returns></returns>
        protected override int GetPeriodGrouping()
        {
            // Grouping:
                //None,
		        //ByInterval,
		        //ByHourOfDay,
		        //ByDayOfWeek,
		        //ByDayOfMonth,
		        //ByWeekOfYear,
		        //ByMonthOfYear,
		        //ByYear,
		        //ByWeekOfMonth,
		        //AllData,
		        //ByAbsoluteDayOfMonth
            return (int)Grouping.ByInterval;
        }


        /// <summary>
        /// This override is where our custom logic will run.
        /// </summary>
        /// <remarks>
        /// The base classes will handle expections, although they do this by failing the request. 
        /// ArgumentException or any of its sub classes will result in a HTTP 400 status code.
        /// Any other exception type will result in a HTTP 500 status code.
        /// </remarks>
        /// <param name="seriesData">
        /// Series data as returned by the provider engine. If period grouping and aggregation
        /// are enabled those grouping and roll ups will already be done. 
        /// </param>
        /// <returns>
        /// An object that will be JSON serialized and sent to the browser.
        /// The data reader base classes do not require or enforce any specific type.
        /// This example uses anonymous classes, but a traditional class-based data transport 
        /// object will work, as will a dynamic object.
        /// </returns>
        /*
        protected override object PostProcessSeriesCollectionData(SeriesCollectionModelView seriesData)
        {
            // JavaScript code is simpler if we return an empty response.
            // This might not always be the correct response for null series data!
            if (seriesData == null) return CreateEmptyResponse();
            var data = seriesData.DataSeriesList.FirstOrDefault();
            if (data == null) return CreateEmptyResponse();
            // Process the data. 
            foreach (var value in data.Values)
            {
                UpdateValues(value);
            }
            avg = (count > 0) ? sum / count : 0;

            string unitName = GetUnitName();

            return CreateResponse(data.StartDateDisplayString, data.EndDateDisplayString, unitName);
        }


        #region Min/Max/Average Implementation

        int count;
        double sum;
        private double avg;
        double min = double.MaxValue;
        double max = double.MinValue;
        DateTime mintime = DateTime.Today;
        DateTime maxtime = DateTime.Today;


        private void UpdateValues(LabeledValue value)
        {
            if (double.IsNaN(value.Value)) return;
            count++;
            sum += value.Value;
            if (min > value.Value)
            {
                min = value.Value;
                mintime = value.TimestampLocal;
            }
            if (max < value.Value)
            {
                max = value.Value;
                maxtime = value.TimestampLocal;
            }
        }

        private object CreateEmptyResponse()
        {
            return CreateResponse(string.Empty, string.Empty, string.Empty);
        }

        private string GetUnitName()
        {
            string utilName = PrimaryDataSeries.Count > 0 ? PrimaryDataSeries[0].UnitName : string.Empty;
            return utilName;
        }

        private object CreateResponse(string startDateText, string endDateText, string unit)
        {
            // Create an anonymous class for consumption by the client. 
            // This makes it easy to support JavaScript-style lowercase property names.
            // Having the type created in one place ensures consistency.
            return new
            {
                count,
                sum,
                avg,
                min,
                max,
                mintime,
                maxtime,
                startDateText,
                endDateText,
                unit
            };

        }

        #endregion
        */
    }
}