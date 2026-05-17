/// A single point in a workspace-aggregated time series. [day] is the
/// snapshot's bucket truncated to UTC midnight; [value] is the sum
/// across every account that reported that metric on that day.
class TimeSeriesPoint {
  const TimeSeriesPoint({required this.day, required this.value});

  final DateTime day;
  final int value;
}
