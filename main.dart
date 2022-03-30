class NewStudent {
  String name;
  String email;
  NewStudent({required this.name, required this.email});
}

class StudentRegistered extends NewStudent {
  String id;

  StudentRegistered(
      {required this.id, required String name, required String email})
      : super(name: name, email: email);
}

abstract class RegisterStudent {
  Future<StudentRegistered> registerStudent(NewStudent newStudent);
}

abstract class SendEmail {
  Future<void> sendEmail(NewStudent newStudent);
}

abstract class UpdateStudent {
  Future<StudentRegistered> updateStudent(
      StudentRegistered studentRegistered, NewStudent newStudent);
}

class UpdateStudentImplementation implements UpdateStudent {
  final UpdateStudent _updateStudent;

  UpdateStudentImplementation({required UpdateStudent updateStudent})
      : _updateStudent = updateStudent;

  @override
  Future<StudentRegistered> updateStudent(
      StudentRegistered studentRegistered, NewStudent newStudent) {
    return _updateStudent.updateStudent(studentRegistered, newStudent);
  }
}

class RegisterStudentImplementation implements RegisterStudent {
  final RegisterStudent _registerStudent;
  final SendEmail _sendEmail;

  RegisterStudentImplementation(
      {required RegisterStudent registerStudent, required SendEmail sendEmail})
      : _registerStudent = registerStudent,
        _sendEmail = sendEmail;

  @override
  Future<StudentRegistered> registerStudent(NewStudent newStudent) async {
    StudentRegistered studentRegistered =
        await _registerStudent.registerStudent(newStudent);
    await _sendEmail.sendEmail(newStudent);
    return studentRegistered;
  }
}

class RegisterStudentToMySql implements RegisterStudent {
  @override
  Future<StudentRegistered> registerStudent(NewStudent newStudent) async {
    /*
       Aqui vai a implementação do MySql
   */
    print('${newStudent.name} registrado com sucesso no MySql');
    return StudentRegistered(
        name: newStudent.name, email: newStudent.email, id: '123456');
  }
}

class RegisterStudentToFireStore implements RegisterStudent {
  @override
  Future<StudentRegistered> registerStudent(NewStudent newStudent) async {
    /*
        Aqui vai a implementação do FireStore
    */
    print('${newStudent.name} registrado com sucesso no FireStore');
    return StudentRegistered(
        name: newStudent.name, email: newStudent.email, id: '123456');
  }
}

class UpdatesToFireStore implements UpdateStudent {
  @override
  Future<StudentRegistered> updateStudent(
      StudentRegistered oldStudent, NewStudent newStudent) async {
    /*
        Implementação da atualização dos dados no FireBase
    */
    print(
        'O Estudante de Id:${oldStudent.id} teve o nome alterado para ${newStudent.name} e o e-mail alterado para ${newStudent.email}');
    return StudentRegistered(
        id: oldStudent.id, name: newStudent.name, email: newStudent.email);
  }
}

class SendEmailWithGmail implements SendEmail {
  @override
  Future<void> sendEmail(NewStudent newStudent) async {
    /*
        Os meios de enviar o e-mail com o gmail devem ser implementados aqui
      */
    print(
        'Boas Vindas ${newStudent.name} enviado para ${newStudent.email} via Gmail');
  }
}

class Account implements RegisterStudent, UpdateStudent {
  final RegisterStudentImplementation _registerStudent =
      RegisterStudentImplementation(
          registerStudent: RegisterStudentToFireStore(),
          sendEmail: SendEmailWithGmail());
  final UpdateStudentImplementation _updateStudent =
      UpdateStudentImplementation(updateStudent: UpdatesToFireStore());

  @override
  Future<StudentRegistered> registerStudent(NewStudent newStudent) {
    return _registerStudent.registerStudent(newStudent);
  }

  @override
  Future<StudentRegistered> updateStudent(
      StudentRegistered studentRegistered, NewStudent newStudent) {
    return _updateStudent.updateStudent(studentRegistered, newStudent);
  }
}

main() async {
  StudentRegistered studentRegistered = await Account().registerStudent(
      NewStudent(name: 'Camilo', email: 'camilo.coelho.gomes@gmail.com'));
  Account().updateStudent(studentRegistered,
      NewStudent(name: 'Camilo Coelho', email: 'camilo.coelho@hotmail.com'));
}
