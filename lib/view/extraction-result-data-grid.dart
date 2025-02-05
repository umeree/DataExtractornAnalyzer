import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ExtractionResultDataGrid extends StatefulWidget {
  const ExtractionResultDataGrid({super.key});

  @override
  State<ExtractionResultDataGrid> createState() => _ExtractionResultDataGridState();
}

class _ExtractionResultDataGridState extends State<ExtractionResultDataGrid> {
  late EmployeeDataSource _employeeDataSource;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _employeeDataSource = EmployeeDataSource(employees: getEmployees());
  }
  
  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
        source: _employeeDataSource,
        allowEditing: true,
        columns: [
          GridColumn(
              columnName: 'id',
              label: Center(child: Text("ID"),),
              allowEditing: false,
          ),
          GridColumn(
            columnName: 'name',
            label: Center(child: Text("Name"),),
            allowEditing: true,
          ),
          GridColumn(
            columnName: 'designation',
            label: Center(child: Text("Designation"),),
            allowEditing: true,
          ),
        ]
    );
  }
  List<Employee> getEmployees() {
    return [
      Employee(1, 'John', 'Manager'),
      Employee(2, 'Doe', 'Developer'),
      Employee(3, 'Jane', 'Designer'),
    ];
  }
}



class Employee {
  final int id;
  String name;
  String designation;

  Employee(this.id, this.name, this.designation);
}

class EmployeeDataSource extends DataGridSource {
  List<DataGridRow> _employees = [];

  EmployeeDataSource({required List<Employee> employees}){
    _employees = employees.map<DataGridRow>((emplyoee) => DataGridRow(cells: [
      DataGridCell<int>(
          columnName: 'id', value: emplyoee.id),
      DataGridCell<String>(
          columnName: 'name', value: emplyoee.name),
      DataGridCell<String>(
          columnName: 'designation', value: emplyoee.designation),
    ])).toList();
  }

  List<DataGridRow> get rows => _employees;

  @override
  // Widget buildEditWidget(DataGridRow row, DataGridCell cell, bool isEditing) {
  //   // Custom edit widget for each cell
  //   return TextField(
  //     controller: TextEditingController(text: cell.value.toString()),
  //     onSubmitted: (newValue) {
  //       // Update the data source with the new value
  //       final int rowIndex = _employees.indexOf(row);
  //       if (cell.columnName == 'name') {
  //         _employees[rowIndex].getCells().firstWhere((c) => c.columnName == 'name').value = newValue;
  //       } else if (cell.columnName == 'designation') {
  //         _employees[rowIndex]
  //             .getCells()
  //             .firstWhere((c) => c.columnName == 'designation')
  //             .value = newValue;
  //       }
  //       notifyListeners();
  //     },
  //   );
  // }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    throw UnimplementedError();
  }
}
