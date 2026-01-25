import '../entities/filiere.dart';
import '../entities/epreuve.dart';

abstract class IExamRepository {
  Future<List<Filiere>> getFilieres();
  Future<void> saveFiliere(Filiere filiere);
  Future<void> deleteFiliere(String id);
  
  // Epreuve management
  // Depending on implementation, this might update the Filiere or a separate collection
  Future<void> addEpreuve(Epreuve epreuve);
  Future<void> updateEpreuve(Epreuve epreuve);
  Future<void> deleteEpreuve(String id);
}
