import 'package:flutter_sharing_intent/model/sharing_file.dart';
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
    await _createDB(_database!,1);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(path, version: 1,onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktUserMast (
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
      CREATE TABLE IF NOT EXISTS tktUserList (
        empId TEXT,
        empName TEXT,
        email TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktTaskHdr (
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
      CREATE TABLE IF NOT EXISTS tktTaskDtlAssignTo (
        tktNo TEXT,
        tktAssignedTo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktTaskDtlCopyTo (
        tktNo TEXT,
        tktCopiedTo TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktTaskDtlTags (
        tktNo TEXT,
        tags TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktTaskAttachments (
        tktNo TEXT,
        docid TEXT,
        addedBy TEXT,
        addedOn TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktTaskTags (
        tag TEXT,
        sortOrder INTEGER PRIMARY KEY
      )
    ''');

     await db.execute('''
      CREATE TABLE IF NOT EXISTS tktUserOthDtls (
        empId TEXT,
        shrtName TEXT
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
      await db.rawInsert('INSERT INTO tktUserOthDtls(empId,shrtName) VALUES(?,?)', [x.empId,x.shrtName]);
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

  Future createTktDtlTagList(List<TktDtlTag> t) async {
    final db = await instance.database;
    for (TktDtlTag x in t) {
      await db.delete('tktTaskDtlTags',
          where: "tktNo = ? and tags=?", whereArgs: [x.tktNo, x.tags]);
      await db.insert('tktTaskDtlTags', x.toJson());
    }
  }

  Future createTktHdr(TktHdr t) async {
    final db = await instance.database;
    await db.delete('tktTaskHdr',
          where: "tktNo = ?",
          whereArgs: [t.tktNo]);
    await db.insert('tktTaskHdr', t.toJson());
  }

  Future createTktDtlAssignTo(TktDtlAssign t) async {
    final db = await instance.database;
    await db.delete('tktTaskDtlAssignTo',
          where: "tktNo = ?",
          whereArgs: [t.tktNo]);
    await db.insert('tktTaskDtlAssignTo', t.toJson());
  }

  Future createTktDtlCopyTo(TktDtlCopy t) async {
    final db = await instance.database;
    await db.delete('tktTaskDtlCopyTo',
          where: "tktNo = ?",
          whereArgs: [t.tktNo]);
    await db.insert('tktTaskDtlCopyTo', t.toJson());
  }

  Future createTktDtlTag(TktDtlTag t) async {
    final db = await instance.database;
    await db.insert('tktTaskDtlTags', t.toJson());
  }

  Future updateTktStats(String tktNo, String tktStatus) async {
    final db = await instance.database;
    await db.rawUpdate('UPDATE tktTaskHdr SET tktStatus = ? WHERE tktNo = ?',
        [tktStatus, tktNo]);
  }

  Future createTag(String tag) async {
    final db = await instance.database;
    await db.delete('tktTaskTags', where: "tag = ?", whereArgs: [tag]);
    await db.rawInsert('INSERT INTO tktTaskTags(tag) VALUES(?)', [tag]);
  }
  Future createSharedFile(List<SharedFile> file) async {
    
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktSharedFiles (
        file TEXT,
        file_name
      )
    ''');
    await db.delete('tktSharedFiles');
    for(SharedFile x in file){
      await db.rawInsert('INSERT INTO tktSharedFiles(file) VALUES(?)', [x.value]);
    } 
  }
  Future deleteSharedFiles() async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktSharedFiles (
        file TEXT,
        file_name
      )
    ''');
    await db.delete('tktSharedFiles');   
  }
  Future getSharedFiles() async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tktSharedFiles (
        file TEXT,
        file_name
      )
    ''');
    //var result = await db.rawQuery('SELECT file FROM tktSharedFiles');
    List<Map> result = await db.rawQuery('SELECT file FROM tktSharedFiles');
    return List.generate(
      result.length,
      (i) => TktSharedFile(
        file: result[i]['file'],
      ),
    ).toList();
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
          imgUrl: result[i]['imgUrl'],
          ),
    ).toList();
  }

  Future getTktCount() async {
    final db = await instance.database;
    var result = await db.rawQuery('SELECT tktNo FROM tktTaskHdr');
    return result;
  }

  Future getTktDocCount(String tktNo) async {
    final db = await instance.database;
    var result = await db.rawQuery(
        'SELECT * FROM tktTaskAttachments where tktNo = (\'$tktNo\')');
    return result;
  }

  Future getUserList() async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT a.empId,a.empName,a.email,b.shrtName FROM tktUserList a inner join tktUserOthDtls b on a.empId=b.empId order by empName');
    return List.generate(
      result.length,
      (i) => UserList(
        empId: result[i]['empId'],
        empName: result[i]['empName'],
        email: result[i]['email'],
        shrtName: result[i]['shrtName'],
      ),
    ).toList();
  }

  Future getActionByUserList() async {
    String qry =
        'SELECT DISTINCT a.empId,a.empName FROM tktUserList a inner join tktTaskDtlAssignTo b on a.empId=b.tktAssignedTo order by empName';
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
    String qry = '';
    if (x == 'A') {
      qry =
          'SELECT DISTINCT a.empId,a.empName FROM tktUserList a inner join tktTaskHdr b on a.empId=b.tktCreatedBy where exists ( select 1 from tktTaskDtlAssignTo c inner join tktUserMast d on d.empId=c.tktAssignedTo and c.tktNo=b.tktNo) order by empName';
    } else if (x == 'I') {
      qry =
          'SELECT DISTINCT a.empId,a.empName FROM tktUserList a inner join tktTaskHdr b on a.empId=b.tktCreatedBy where exists ( select 1 from tktTaskDtlCopyTo c inner join tktUserMast d on d.empId=c.tktCopiedTo and c.tktNo=b.tktNo) order by empName';
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

  Future<List<TktCardHdr>> getTktList(
      List<Animal> a, List<String> statusFilter, String from) async {
    final db = await instance.database;
    String qry;
    List<String> animalSelected = [];
    var date = DateTime.now().toString().substring(0, 10);
    for (Animal animal in a) {
      animalSelected.add(animal.empId);
    }
    if (a.isEmpty && statusFilter.isEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists (select 1 from tktUserMast B where B.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    } else if (a.isNotEmpty && statusFilter.isEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists (select 1 from tktTaskDtlAssignTo B, tktUserMast C on A.tktNo=B.tktNo where B.tktAssignedTo IN (\'${animalSelected.join('\',\'')}\') and C.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    } else if (a.isEmpty && statusFilter.isNotEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists (select 1 from tktTaskDtlAssignTo B, tktUserMast C on A.tktNo=B.tktNo and C.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and CASE WHEN \'Overdue\' IN (\'${statusFilter.join('\',\'')}\') THEN strftime(\'%Y-%m-%d\', tktReplyOn)<\'$date\' and tktStatus<>\'Completed\' ELSE A.tktStatus IN (\'${statusFilter.join('\',\'')}\') END INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    } else if (a.isNotEmpty && statusFilter.isNotEmpty) {
      if (from == 'C') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and  A.tktStatus IN (\'${statusFilter.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists (select 1 from tktTaskDtlAssignTo B, tktUserMast C on A.tktNo=B.tktNo where B.tktAssignedTo IN (\'${animalSelected.join('\',\'')}\') and C.empId=A.tktCreatedBy) order by tktCreatedOn desc';
      } else if (from == 'A') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') where exists ( select 1 from tktTaskDtlAssignTo B inner join tktUserMast C on C.empId=B.tktAssignedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else if (from == 'I') {
        qry =
            'SELECT A.tktNo, A.tktTitle, A.tktDesc, A.tktCreatedBy, A.tktCreatedOn, A.tktReplyOn, A.tktStatus, c.shrtName as empName, (SELECT COUNT(docid) FROM tktTaskAttachments B WHERE A.tktNo=B.tktNo) as tktDocCnt,(select C.shrtName from tktTaskDtlAssignTo B INNER JOIN tktUserOthdtls C on B.tktAssignedTo=c.empId WHERE A.tktNo=B.tktNo order by C.shrtName limit 1) as tktAssignedTo FROM tktTaskHdr A INNER JOIN tktUserList B on A.tktCreatedBy=B.empId and A.tktStatus IN (\'${statusFilter.join('\',\'')}\') and A.tktCreatedBy IN (\'${animalSelected.join('\',\'')}\') INNER JOIN tktUserOthdtls C on B.empId=c.empId where exists ( select 1 from tktTaskDtlCopyTo B inner join tktUserMast C on C.empId=B.tktCopiedTo and B.tktNo=A.tktNo) order by tktCreatedOn desc';
      } else {
        qry = '';
      }
    } else {
      qry = '';
    }

    List<Map> result = await db.rawQuery(qry);
    return List.generate(
      result.length,
      (i) => TktCardHdr(
        tktNo: result[i]['tktNo'],
        tktTitle: result[i]['tktTitle'],
        tktDesc: result[i]['tktDesc'],
        tktCreatedBy: result[i]['empName'],
        tktAssignedTo: result[i]['tktAssignedTo'],
        tktCreatedOn: result[i]['tktCreatedOn'],
        tktReplyOn: result[i]['tktReplyOn'],
        tktStatus: result[i]['tktStatus'],
        tktDocCnt: result[i]['tktDocCnt'],
      ),
    ).toList();
  }

  Future getTagList() async {
    final db = await instance.database;
    List<Map> result = await db
        .rawQuery('SELECT tag FROM tktTaskTags order by sortOrder desc');
    return List.generate(
      result.length,
      (i) => Tags(
        tag: result[i]['tag'],
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
    List<Map> result =
        await db.query('tktTaskHdr', where: "tktNo = ?", whereArgs: [tktNo]);
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
        shrtName: '',
      ),
    ).toList();
  }

  Future getTktDetailCopyTo(String tktNo) async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT B.empId, B.empName FROM tktTaskDtlCopyTo A INNER JOIN tktUserList B ON A.tktCopiedTo=B.empId AND A.tktNo = (\'$tktNo\')');
    return List.generate(
      result.length,
      (i) => UserList(
        empId: result[i]['empId'],
        empName: result[i]['empName'],
        email: '',
        shrtName: '',
      ),
    ).toList();
  }

  Future getTktDetailTags(String tktNo) async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT A.tags FROM tktTaskDtlTags A WHERE A.tktNo = (\'$tktNo\')');
    return List.generate(
      result.length,
      (i) => Tags(
         tag: result[i]['tags'],
      ),
    ).toList();
  }

  Future getTktAttachmentDetail(String tktNo) async {
    final db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT A.tktNo,A.docid, B.empName as addedBy,A.addedOn FROM tktTaskAttachments A INNER JOIN tktUserList B ON A.addedBy=B.empId AND A.tktNo = (\'$tktNo\') order by A.docid,A.addedOn');
    return List.generate(
      result.length,
      (i) => TktDtlAttachment(
        tktNo: result[i]['tktNo'],
        docid: result[i]['docid'],
        addedBy: result[i]['addedBy'],
        addedOn: result[i]['addedOn'],
      ),
    ).toList();
  }

  Future getTktStsCount(String empId) async {
    final db = await instance.database;
    DateTime now = DateTime.now();
    var date = now.toString().substring(0, 10);
    List<Map> result = await db.rawQuery(
        'select cast(sum(case when tktStatus=\'Raised\' then 1 else 0 end) as TEXT) black,cast(sum(case when tktStatus=\'Progress\' then 1 else 0 end) as TEXT) yellow,cast(sum(case when tktStatus=\'Completed\' then 1 else 0 end) as TEXT) blue,cast(sum(case when strftime(\'%Y-%m-%d\', tktReplyOn)<\'$date\' and tktStatus<>\'Completed\' then 1 else 0 end) as TEXT) red from tktTaskHdr A inner join tktTaskDtlAssignTo B on A.tktNo=B.tktNo and B.tktAssignedTo = (\'$empId\')');
    return List.generate(
      result.length,
      (i) => TktStsCount(
        black: result[i]['black'],
        yellow: result[i]['yellow'],
        blue: result[i]['blue'],
        red: result[i]['red'],
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
    await db.delete('tktuserOthdtls');
  }
  Future deleteTkts() async{
    final db = await instance.database;
    await db.delete('tktTaskHdr');
    await db.delete('tktTaskDtlAssignTo');
    await db.delete('tktTaskDtlCopyTo');
    await db.delete('tktTaskDtlTags');
  }
  Future createTktAttachments(List<TktDtlAttachment> t) async {
    final db = await instance.database;
    if (t.isEmpty) {
      return;
    }

    for (TktDtlAttachment x in t) {
      await db.delete('tktTaskAttachments',
          where: "tktNo = ? and docid=?", whereArgs: [x.tktNo, x.docid]);
      await db.insert('tktTaskAttachments', x.toJson());
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
