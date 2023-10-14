import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:firebase_auth/firebase_auth.dart';

//temp data
class DailyLog {
  final int waterIntake;
  final int steps;
  final String activity;
  final Duration sleepDuration;
  DailyLog(
      {required this.waterIntake,
      required this.steps,
      required this.activity,
      required this.sleepDuration});
}

/////////////////////////////////////////////////////////

class PersonalCareScreen extends StatefulWidget {
  const PersonalCareScreen({Key? key}) : super(key: key);

  @override
  _PersonalCareScreenState createState() => _PersonalCareScreenState();
}

class _PersonalCareScreenState extends State<PersonalCareScreen> {
  int _waterIntake = 0;
  String _steps = '';
  String _selectedActivity = 'Nothing';
  String _selectedDuration = '';
  Duration? _sleepDuration;

  List<DailyLog> logs = [];

  void logData() {
    DailyLog todayLog = DailyLog(
      waterIntake: _waterIntake,
      steps: int.tryParse(_steps) ?? 0,
      activity: _selectedActivity,
      sleepDuration: _sleepDuration ?? Duration(hours: 0),
    );
    setState(() {
      logs.add(todayLog);
    });
  }

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  int _currentIndex = 0;

  @override
  void dispose() {
    _stepsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Care'),
      ),
      body: _currentIndex == 0
          ? _buildPersonalCareContent()
          : LogScreen(logs: logs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Logs",
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalCareContent() {
    return Padding(
      padding: const EdgeInsets.all(2.1),
      child: ListView(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                SizedBox(height: 8),
                Text(
                  'Hi, John Doe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOvalContainer(
                  title: 'Weight',
                  value: '68 kg',
                  onTap: () async {
                    String? newWeight =
                        await _showEditDialog(context, 'Edit Weight', '68');
                    if (newWeight != null) {
                      setState(() {});
                    }
                  }),
              _buildOvalContainer(
                title: 'Progress',
                child: LinearProgressIndicator(
                  value: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              WaterIntakeCard(
                  waterIntake: _waterIntake,
                  onUpdate: (int value) =>
                      setState(() => _waterIntake = value)),
              StepsCard(
                  steps: _steps,
                  onUpdate: (String value) => setState(() => _steps = value)),
              ActivityCard(
                  selectedActivity: _selectedActivity,
                  selectedDuration: _selectedDuration,
                  onUpdateActivity: (String value) =>
                      setState(() => _selectedActivity = value),
                  onUpdateDuration: (String value) =>
                      setState(() => _selectedDuration = value)),
              SleepCard(
                  sleepDuration: _sleepDuration ?? Duration(hours: 8),
                  onUpdate: (Duration value) =>
                      setState(() => _sleepDuration = value)),
            ],
          ),
          ElevatedButton(
            onPressed: logData,
            child: Text("Log"),
          )
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOvalContainer({
    required String title,
    String? value,
    Widget? child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (value != null)
                Text(value,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (child != null) child,
              SizedBox(height: 8),
              Text(title),
            ],
          ),
        ));
  }

  Future<void> _showSleepPicker() async {
    String newSleepDuration =
        '${_sleepDuration?.inHours ?? 0} hours ${_sleepDuration?.inMinutes.remainder(60) ?? 0} minutes';
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TimePickerSpinner(
                    is24HourMode: true,
                    itemHeight: 30,
                    isForce2Digits: true,
                    onTimeChange: (DateTime time) {
                      setState(() {
                        newSleepDuration =
                            '${time.hour} hours ${time.minute} minutes';
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final hours = int.parse(newSleepDuration.split(' ')[0]);
                      final minutes = int.parse(newSleepDuration.split(' ')[2]);
                      setState(() {
                        _sleepDuration =
                            Duration(hours: hours, minutes: minutes);
                      });
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class WaterIntakeCard extends StatefulWidget {
  final int waterIntake;
  final Function(int) onUpdate;

  WaterIntakeCard({required this.waterIntake, required this.onUpdate});

  @override
  _WaterIntakeCardState createState() => _WaterIntakeCardState();
}

class _WaterIntakeCardState extends State<WaterIntakeCard> {
  int _waterIntake = 0;
  @override
  void initState() {
    super.initState();
    _waterIntake = widget.waterIntake;
  }

  void _incrementWaterIntake() {
    setState(() {
      _waterIntake++;
      widget.onUpdate(_waterIntake);
    });
  }

  void _decrementWaterIntake() {
    setState(() {
      if (_waterIntake > 0) {
        _waterIntake--;
        widget.onUpdate(_waterIntake);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Water Intake',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '$_waterIntake glasses',
              style: TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: _decrementWaterIntake,
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _incrementWaterIntake,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StepsCard extends StatefulWidget {
  final String steps;
  final Function(String) onUpdate;

  StepsCard({required this.steps, required this.onUpdate});

  @override
  _StepsCardState createState() => _StepsCardState();
}

class _StepsCardState extends State<StepsCard> {
  final TextEditingController _stepsController = TextEditingController();
  bool _isEditing = false;
  String _steps = '';

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Steps',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _isEditing
                ? TextField(
                    controller: _stepsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter steps',
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _steps = value;
                        _isEditing = false;
                      });
                    },
                  )
                : GestureDetector(
                    onTap: _toggleEditing,
                    child: Text(
                      _steps.isEmpty ? 'Tap to enter steps' : '$_steps steps',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ActivityCard extends StatefulWidget {
  final String selectedActivity;
  final String selectedDuration;
  final Function(String) onUpdateActivity;
  final Function(String) onUpdateDuration;

  ActivityCard({
    required this.selectedActivity,
    required this.selectedDuration,
    required this.onUpdateActivity,
    required this.onUpdateDuration,
  });

  @override
  _ActivityCardState createState() => _ActivityCardState();
}

class SleepCard extends StatefulWidget {
  final Duration sleepDuration;
  final Function(Duration) onUpdate;

  SleepCard({required this.sleepDuration, required this.onUpdate});

  @override
  _SleepCardState createState() => _SleepCardState();
}

class _SleepCardState extends State<SleepCard> {
  TimeOfDay? _sleepTime;
  TimeOfDay? _wakeTime;
  Duration? _sleepDuration;

  Future<void> _showSleepTimePicker() async {
    final TimeOfDay? pickedSleepTime = await showTimePicker(
      context: context,
      initialTime: _sleepTime ?? TimeOfDay(hour: 22, minute: 0),
    );
    if (pickedSleepTime != null) {
      setState(() {
        _sleepTime = pickedSleepTime;
        _calculateSleepDuration();
      });
    }
  }

  Future<void> _showWakeTimePicker() async {
    final TimeOfDay? pickedWakeTime = await showTimePicker(
      context: context,
      initialTime: _wakeTime ?? TimeOfDay(hour: 6, minute: 0),
    );
    if (pickedWakeTime != null) {
      setState(() {
        _wakeTime = pickedWakeTime;
        _calculateSleepDuration();
      });
    }
  }

  void _calculateSleepDuration() {
    if (_sleepTime != null && _wakeTime != null) {
      final sleepDateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, _sleepTime!.hour, _sleepTime!.minute);
      final wakeDateTime = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, _wakeTime!.hour, _wakeTime!.minute);
      final sleepDuration = wakeDateTime.isBefore(sleepDateTime)
          ? wakeDateTime.add(Duration(days: 1)).difference(sleepDateTime)
          : wakeDateTime.difference(sleepDateTime);

      setState(() {
        _sleepDuration = sleepDuration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _showSleepTimePicker();
        await _showWakeTimePicker();
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sleep',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                _sleepDuration == null
                    ? 'Tap to enter sleep time'
                    : '${_sleepDuration!.inHours} hours ${_sleepDuration!.inMinutes.remainder(60)} minutes',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCardState extends State<ActivityCard> {
  String _selectedActivity = '';
  String _selectedDuration = '';

  Future<void> _showActivityPicker() async {
    String newActivity =
        _selectedActivity.isEmpty ? 'Walking' : _selectedActivity;
    String newDuration =
        _selectedDuration.isEmpty ? '0 hours 0 minutes' : _selectedDuration;

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: newActivity,
                    items: <String>[
                      'Walking',
                      'Jogging',
                      'Cycling',
                      'Weightlifting',
                      'Other',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        newActivity = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TimePickerSpinner(
                    is24HourMode: true,
                    itemHeight: 30,
                    isForce2Digits: true,
                    onTimeChange: (DateTime time) {
                      setState(() {
                        newDuration =
                            '${time.hour} hours ${time.minute} minutes';
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedActivity = newActivity;
                        _selectedDuration = newDuration;
                      });
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showActivityPicker,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                _selectedActivity.isEmpty
                    ? 'Tap to select activity'
                    : '$_selectedActivity for $_selectedDuration',
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildFeatureCard({
  required String title,
  required String content,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    ),
  );
}

class LogScreen extends StatefulWidget {
  final List<DailyLog> logs;
  LogScreen({required this.logs});
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.logs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: widget.logs
              .map((log) => Tab(text: "Day ${widget.logs.indexOf(log) + 1}"))
              .toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.logs.map((log) => DayLog(log)).toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}

class DayLog extends StatelessWidget {
  final DailyLog log;
  DayLog(this.log);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.local_drink),
          title: Text("Water Intake"),
          subtitle: Text("${log.waterIntake} glasses"),
        ),
        ListTile(
          leading: Icon(Icons.directions_walk),
          title: Text("Steps"),
          subtitle: Text("${log.steps} steps"),
        ),
        ListTile(
          leading: Icon(Icons.run_circle),
          title: Text("Activity"),
          subtitle: Text(
              "${log.activity} for ${log.sleepDuration.inHours} hours ${log.sleepDuration.inMinutes.remainder(60)} minutes"),
        ),
        ListTile(
          leading: Icon(Icons.bedtime),
          title: Text("Sleep Duration"),
          subtitle: Text(
              "${log.sleepDuration.inHours} hours ${log.sleepDuration.inMinutes.remainder(60)} minutes"),
        ),
        Container(
          height: 250,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        )
      ],
    );
  }
}

// Widget buildStepsLineChart() {
//   return LineChart(
//     LineChartData(
//       gridData: FlGridData(show: false),
//       titlesData: FlTitlesData(show: false),
//       borderData: FlBorderData(
//           show: true,
//           border: Border.all(color: const Color(0xff37434d), width: 1)),
//       minX: 0,
//       maxX: 6, // For a week
//       minY: 0,
//       maxY: 15000, // Assuming max steps can be 15k
//       lineBarsData: [
//         LineChartBarData(
//           spots: [
//             FlSpot(0, 5000),
//             FlSpot(1, 7000),
//             // ... Add spots for each day
//           ],
//           isCurved: true,
//           colors: [Colors.blue],
//           barWidth: 4,
//           isStrokeCapRound: true,
//           belowBarData: BarAreaData(show: false),
//         ),
//       ],
//     ),
//   );
// }
Future<String?> _showEditDialog(
    BuildContext context, String title, String initialValue) async {
  TextEditingController controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter new value',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      );
    },
  );
}
