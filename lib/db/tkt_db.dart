import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ticket_app/models/userList.dart';
import '../models/tkt.dart';
import '../models/user.dart';

class TktDb {
  static final TktDb instance = TktDb._init();

  static Database? _database;

  TktDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tkt.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tktUserMast (
        devId INTEGER,
        empId TEXT,
        empName TEXT,
        dsgntn TEXT,
        mob TEXT,
        loctn TEXT,
        usrTyp TEXT,
        dpt TEXT,
        gender TEXT,
        imgUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tktUserList (
        empId TEXT,
        empName TEXT,
        email TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tktTaskHdr (
        tktNo TEXT,
        tktTitle TEXT,
        tktDesc TEXT,
        tktCreatedBy TEXT,
        tktCreatedOn TEXT,
        tktReplyOn TEXT,
        tktStatus TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tktTaskDtlAssignTo (
        tktNo TEXT,
        tktAssignedTo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE tktTaskDtlCopyTo (
        tktNo TEXT,
        tktCopiedTo TEXT
      )
    ''');
  }

  Future createUser(User user) async {
    final db = await instance.database;
    await db.insert('tktUserMast', user.toJson());
  }

  Future createUserList(List<UserList> ul) async {
    final db = await instance.database;
    for (UserList x in ul) {
      await db.insert('tktUserList', x.toJson());
    }
  }

  Future createTktHdrList(List<TktHdr> t) async {
    final db = await instance.database;
    for (TktHdr x in t) {
      await db.delete('tktTaskHdr', where: "tktNo = ?", whereArgs: [x.tktNo]);
      await db.insert('tktTaskHdr', x.toJson());
    }
  }

  Future createTktDtlAssignToList(List<TktDtlAssign> t) async {
    final db = await instance.database;
    for (TktDtlAssign x in t) {
      await db.delete('tktTaskDtlAssignTo',
          where: "tktNo = ? and tktAssignedTo=?",
          whereArgs: [x.tktNo, x.tktAssignedTo]);
      await db.insert('tktTaskDtlAssignTo', x.toJson());
    }
  }

  Future createTktDtlCopyToList(List<TktDtlCopy> t) async {
    final db = await instance.database;
    for (TktDtlCopy x in t) {
      await db.delete('tktTaskDtlCopyTo',
          where: "tktNo = ? and tktCopiedTo=?",
          whereArgs: [x.tktNo, x.tktCopiedTo]);
      await db.insert('tktTaskDtlCopyTo', x.toJson());
    }
  }

  Future createTktHdr(TktHdr t) async {
    final db = await instance.database;
    await db.insert('tktTaskHdr', t.toJson());
  }

  Future createTktDtlAssignTo(TktDtlAssign t) async {
    final db = await instance.database;
    await db.insert('tktTaskDtlAssignTo', t.toJson());
  }

  Future createTktDtlCopyTo(TktDtlCopy t) async {
    final db = await instance.database;
    await db.insert('tktTaskDtlCopyTo', t.toJson());
  }

  Future updateTktStats(String tktNo, String tktStatus) async {
    final db = await instance.database;
    await db.rawUpdate('UPDATE tktTaskHdr SET tktStatus = ? WHERE tktNo = ?',[tktStatus, tktNo]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future getUserInfo() async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT * FROM tktUserMast');
    return List.generate(
      result.length,
      (i) => User(
          devid: result[i]['devId'],
          empId: result[i]['empId'],
          empName: result[i]['empName'],
          dsgntn: result[i]['dsgntn'],
          mob: result[i]['mob'],
          loctn: result[i]['loctn'],
          usrTyp: result[i]['usrTyp'],
          dpt: result[i]['dpt'],
          gender: result[i]['gender'],
          imgUrl: result[i]['imgUrl']),
    ).toList();
  }

  Future getTktCount() async {
    final db = await instance.database;
    var result = await db.rawQuery('SELECT tktNo FROM tktTaskHdr');
    return result;
  }

  Future getUserList() async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT empId,empName,email FROM tktUserList order by empName');
    return List.generate(
      result.length,
      (i) => UserList(
        empId: result[i]['empId'],
        empName: result[i]['empName'],
        email: result[i]['email'],
      ),
    ).toList();
  }

  Future getActionByUserList() async {
    String qry='SELECT DISTINCT a.empId,a.empName FROM tktUserList a inner join tktTaskDtlAssignTo b on a.empId=b.tktAssignedTo order by empName';
    final db = await instance.database;
    List<Map> result = await db.rawQuery(qry);
    return List.generate(
      result.length,
      (i) => Animal(
        empId: result[i]['empId'],
        empName: result[i]['empName'],
      ),
    ).toList();
  }
  Future getRaisedByUserList(String x) async {
    String qry='';
    if(x=='A'){
      qry='SELECT DISTINCT a.empId,a.empName FROM tktUserList a inner join tktTaskHdr b on a.empId=b.tktCreatedBy where exists ( select 1 from tktTaskDtlAssignTo c inner join tktUserMast d on d.empId=c.tktAssignedTo and c.tktNo=b.tktNo) order by empName';
    }
    else if(x=='I'){
      qry = 'SELECT DISTINCT a.empId,a.empName FROM tktUserList a inner join tktTaskHdr b on a.empId=b.tktCreatedBy where exists ( select 1 from tktTaskDtlCopyTo c inner join tktUserMast d on d.empId=c.tktCopiedTo and c.tktNo=b.tktNo) order by empName';
    }
    
    final db = await instance.database;
    List<Map> result = await db.rawQuery(qry);
    return List.generate(
      result.length,
      (i) => Animal(
        empId: result[i]['empId'],
        empName: result[i]['empName'],
      ),
    ).toList();
  }
  Future<List<TktHdr>> getTktList(List<Animal> a, List<String> statusFilter, String from) async {
    final db = await instance.database;
    String qry;
    List<String> animalSelected = [];
    for (Animal animal in a) {
      animalSelected.add(animal.empId);
    }
    if (a.isEmpty && statusFilter.isEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId where exists (select 1 from tktUserMast B where B.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    }
    else if (a.isNotEmpty && statusFilter.isEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId where exists (select 1 from tktTaskDtlAssignTo B, tktUserMast C on A.tktNo=B.tktNo where B.tktAssignedTo IN (\'${animalSelected.join('\',\'')}\') and C.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    }
    else if (a.isEmpty && statusFilter.isNotEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') where exists (select 1 from tktTaskDtlAssignTo B, tktUserMast C on A.tktNo=B.tktNo and C.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    }
    else if (a.isNotEmpty && statusFilter.isNotEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and  A.tktStatus IN (\'${statusFilter.join('\',\'')}\') where exists (select 1 from tktTaskDtlAssignTo B, tktUserMast C on A.tktNo=B.tktNo where B.tktAssignedTo IN (\'${animalSelected.join('\',\'')}\') and C.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, B.empName FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    }
    else{
      qry='';
    }

    List<Map> result = await db.rawQuery(qry);
    return List.generate(
      result.length,
      (i) => TktHdr(
        tktNo: result[i]['tktNo'],
        tktTitle: result[i]['tktTitle'],
        tktDesc: result[i]['tktDesc'],
        tktCreatedBy: result[i]['empName'],
        tktCreatedOn: result[i]['tktCreatedOn'],
        tktReplyOn: result[i]['tktReplyOn'],
        tktStatus: result[i]['tktStatus'],
      ),
    ).toList();
  }

  Future getLastTkt() async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT * FROM tktTaskHdr order by  tktCreatedOn desc limit 1');
    return List.generate(
      result.length,
      (i) => TktHdr(
        tktNo: result[i]['tktNo'],
        tktTitle: result[i]['tktTitle'],
        tktDesc: result[i]['tktDesc'],
        tktCreatedBy: result[i]['tktCreatedBy'],
        tktCreatedOn: result[i]['tktCreatedOn'],
        tktReplyOn: result[i]['tktReplyOn'],
        tktStatus: result[i]['tktStatus'],
      ),
    ).toList();
  }

  Future getTktDetail(String tktNo) async {
    final db = await instance.database;
    List<Map> result = await db.query(
        'tktTaskHdr',where: "tktNo = ?",
          whereArgs: [tktNo]);
    return List.generate(
      result.length,
      (i) => TktHdr(
        tktNo: result[i]['tktNo'],
        tktTitle: result[i]['tktTitle'],
        tktDesc: result[i]['tktDesc'],
        tktCreatedBy: result[i]['tktCreatedBy'],
        tktCreatedOn: result[i]['tktCreatedOn'],
        tktReplyOn: result[i]['tktReplyOn'],
        tktStatus: result[i]['tktStatus'],
      ),
    ).toList();
  }
  Future getTktDetailAssignTo(String tktNo) async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT B.empId, B.empName FROM tktTaskDtlAssignTo A INNER JOIN tktUserList B ON A.tktAssignedTo=B.empId AND A.tktNo = (\'$tktNo\')');
    return List.generate(
      result.length,
      (i) => UserList(
        empId: result[i]['empId'],
        empName: result[i]['empName'],
        email: '',
      ),
    ).toList();
  }
  Future getTktStsCount(String empId) async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'select cast(sum(case when tktStatus=\'Raised\' then 1 else 0 end) as TEXT) black,cast(sum(case when tktStatus=\'Progress\' then 1 else 0 end) as TEXT) yellow,cast(sum(case when tktStatus=\'Completed\' then 1 else 0 end) as TEXT) blue from tktTaskHdr A inner join tktTaskDtlAssignTo B on A.tktNo=B.tktNo and B.tktAssignedTo = (\'$empId\')');
    return List.generate(
      result.length,
      (i) => TktStsCount(
        black: result[i]['black'],
        yellow: result[i]['yellow'],
        blue: result[i]['blue'],
        red: '0',
      ),
    ).toList();
  }
  Future deleteUserInfo() async {
    final db = await instance.database;
    await db.delete('tktUserMast');
  }

  Future deleteUserList() async {
    final db = await instance.database;
    await db.delete('tktUserList');
  }
}
