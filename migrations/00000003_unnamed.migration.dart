import 'dart:async';
import 'package:conduit/conduit.dart';   

class Migration3 extends Migration { 
  @override
  Future upgrade() async {
   		database.addColumn("_Note", SchemaColumn("status", ManagedPropertyType.boolean, isPrimaryKey: false, autoincrement: false, isIndexed: false, isNullable: true, isUnique: false));
  }
  
  @override
  Future downgrade() async {}
  
  @override
  Future seed() async {}
}
    