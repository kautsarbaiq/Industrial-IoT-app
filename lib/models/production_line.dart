/// A production line: an aggregation of machines with a rolled-up OEE.
class ProductionLine {
  final String id;
  final String name;
  final int machineCount;
  final int runningCount;
  final double oee;
  final int output;
  final int target;

  const ProductionLine({
    required this.id,
    required this.name,
    required this.machineCount,
    required this.runningCount,
    required this.oee,
    required this.output,
    required this.target,
  });

  double get attainment => target == 0 ? 0 : (output / target) * 100;

  factory ProductionLine.fromJson(Map<String, dynamic> json) => ProductionLine(
        id: json['id'] as String,
        name: json['name'] as String,
        machineCount: (json['machineCount'] as num).toInt(),
        runningCount: (json['runningCount'] as num).toInt(),
        oee: (json['oee'] as num).toDouble(),
        output: (json['output'] as num).toInt(),
        target: (json['target'] as num).toInt(),
      );
}
