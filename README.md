# SOLID e Clean Architeture
 
## Introdução
 
Termos como **SOLID** e **Clean Architeture** são muito comuns de encontrar nas descrições das vagas para desenvolvedores, e que muitas vezes desestimulam pessoas que estão ingressando na carreira, por acharem que não vão dar conta do recado.
 
Então após passar algumas semanas estudando esses termos, decidi fazer esse compilado sobre o que eu aprendi sobre esses termos lendo os livros do Uncle Bob, diversos fóruns na internet, artigos e vídeos no YouTube.
 
## Menção Honrosa ao Clean Code
 
Antes de começar a discussão sobre os temas de SOLID e Clean Architeture vale fazer uma menção ao Clean Code. Os compilados de técnicas e como escrever códigos, a importância dos nomes das classes, dos métodos e funções são a base de tudo que vamos construir e debater aqui. Afinal, antes de construir uma boa casa, precisamos de ótimos tijolos.
 
## Disposição dos Tijolos
 
> *"Bons sistemas de software começam com um código limpo. Por um lado, se os tijolos não são bem feitos, a arquitetura da construção perde a importância. Por outro lado, você consegue fazer uma bagunça danada com tijolos bem-feitos. É aí que entram os princípios do SOLID."* - Escrito por Uncle Bob no livro Arquitetura Limpa.
 
### Exemplo Prático
 
#### Primeiro Pedido
Para seguir com esse estudo vamos começar um desenvolvimento de um sistema simples. O diretor de uma escola quer que você crie um formulário para que ele possa pegar o **NOME** e o **E-MAIL** de cada **ALUNO**.
 
Entretanto, quando você pergunta para o cliente qual o sistema de banco de dados ele quer que utilize e em quais dispositivos esse sistema deve rodar. Sua resposta foi um educado... "Não faço a menor ideia".
 
Entendendo um pouco de SOLID e do paradigma de orientação à objetos, você prontamente diz que tranquilamente, consegue começar a implementar e deixar esses detalhes para depois.
 
Assim para escolher a linguagem para começar a implementar, optamos pelo **Dart** uma linguagem com um paradigma de orientação à objetos muito forte, e que tem um framework muito interessante chamado **Flutter** que pretende programar uma vez e fazer build em todos os dispositivos.
 
E também sabendo que a Arquitetura Limpa prega a independência de frameworks, vamos deixar o Flutter de lado e fazer só a parte do Dart por enquanto.
 
E assim com as poucas informações que você tem, começa a implementação
 
### Primeira Implementação
 
```dart
class NewStudent {
 String name;
 String email;
  NewStudent({required this.name, required this.email});
}
 
class StudentRegistered extends NewStudent {
 String id;
 
 StudentRegistered({required this.id,required String name, required String email}):super(name: name, email: email);
}
  
abstract class RegisterStudent {
 Future<StudentRegistered> registerStudent(NewStudent newStudent);
}
 
class RegisterStentImplementation implements RegisterStudent {
 final RegisterStudent _registerStudent;
  RegisterStentImplementation({required RegisterStudent registerStudent}):_registerStudent = registerStudent;
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent){
   return _registerStudent.registerStudent(newStudent);
 }
}
```
 
#### Análise
 
* **NewStudent:** A classe NewStudent se refere a classe básica que o cliente pediu que fosse registrado desde o início nela aplica-se o **S - Principio da Responsabilidade Única (Single Responsability Principle)**, nele fala que um pedaço de software só deve uma, e única razão para mudar. Nesse caso, a única razão para essa classe mudar é se o cliente quiser coletar mais dados do Usuário do que ele pediu inicialmente.
 
* **StudentRegistered:** Seguindo o  **I - Princípio da Segregação de Interfaces (Interface Segregation Principle)** para não forçar um novo estudante a ter um Id que ele ainda não vai usar nós estendemos a classe NewStudent, que tem os dados do estudante, mais o id dele gerado pelo banco de dados que será utilizado no futuro.
 
* **RegisterStudent:** Para que futuramente possamos seguir o **D - Princípio da Inversão de Dependências (Dependency Inversion Principle)** e o **L - Princípio da Substituição de Liskov (Liskov Substituition Principle)** Deve-se criar as abstrações para que os sistemas implementem elas. Assim iremos poder substituir itens que implementem essas abstrações facilmente entre elas, e podemos facilmente injetar as dependências, desde que elas dependam das mesmas abstrações.
 
* **RegisterStentImplementation:** Essa classe trabalha junto com a anterior e complementa a outra parte do príncipio, quando um banco de dados for definido, ele terá que implementar a classe abstrata RegisterStudent e essa dependência será injetada em nossa implementação por meio de seu construtor, fazendo com que a função de registro não dependa do banco de dados, completando a segunda parte do **D - Princípio da Inversão de Dependências (Dependency Inversion Principle)**.
 
### Segundo Pedido
 
Passa algum tempo, o cliente volta falando que decidiu contratar um sistema de banco de dados em **MySql**, pq ele ouviu de alguém que é o melhor, e que já até comprou todas as licenças que precisa.
 
#### Segunda Implementação
 
```Dart
class RegisterStudentToMySql implements RegisterStudent {
 @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent) async{
   /*
       Aqui vai a implementação do MySql
   */
   print('${newStudent.name} registrado com sucesso no MySql');
   return StudentRegistered(name: newStudent.name,email: newStudent.email,id: '123456');
 }
}
 
class RegisterStudentInjection implements RegisterStudent {
 final RegisterStentImplementation _registerStudent = RegisterStentImplementation(registerStudent: RegisterStudentToMySql());
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent){
   return _registerStudent.registerStudent(newStudent);
 }
}
 
main(){
 RegisterStudentInjection().registerStudent(NewStudent(name:'Camilo',email:'camilo.coelho.gomes@gmail.com'));
}
```
 
#### Segunda Análise
 
* **RegisterStudentToMySql:** essa classe é a única que irá conhecer os métodos do MySql, e deverá fazer com que a abstração do **RegisterStudent** seja cumprida.
 
* **RegisterStudentInjection:** essa classe é a que faz a configuração das injeções de dependências internas, amarrando a última parte do **D**, onde é declarado o método **_registerStudent** que constrói a classe **RegisterStentImplementation** utilizando como parâmetro do seu construtor o **RegisterStudentToMySql()**.
 
* **main:** Aqui ela representa a função que é chamada pelo front para cadastrar um novo aluno, ela não conhece nenhum dos métodos internos e nenhuma outra regra de negócio, executando exatamente o que foi definido na estrutura, sem conhecer os detalhes da implementação.
 
### Terceiro Pedido
 
O cliente te chama desesperado no WhatsApp dizendo que o pessoal do mySql decidiu descontinuar o suporte a algumas funções que ele gostava em outra API que ele usava para BI, então ele vai migrar todo o banco de dados para o FireStore do FireBase.
 
#### Terceira Implementação
 
```Dart
class RegisterStudentToFireStore implements RegisterStudent {
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent) async{
   /*
       Aqui vai a implementação do FireStore
   */
   print('${newStudent.name} registrado com sucesso no FireStore');
   return StudentRegistered(name: newStudent.name,email: newStudent.email,id: '123456');
 }
}
 
class RegisterStudentInjection implements RegisterStudent {
 final RegisterStentImplementation _registerStudent = RegisterStentImplementation(registerStudent: RegisterStudentToFireStore());
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent){
   return _registerStudent.registerStudent(newStudent);
 }
}
```
 
#### Terceira Análise
 
* **RegisterStudentToFireStore:** Essa classe tem a mesma idéia da **RegisterStudentToMySql**, ela simplesmente implementa a abstração do **RegisterStudent**. Isso pode ser feito por termos seguido o princípio do **D - Princípio da Inversão de Dependência**, ela vai poder ser chamada pelo construtor do **RegisterStentImplementation**.
 
* **RegisterStudentInjection:** Essa classe não foi recriada, só modificada. Por termos seguido o **L - Príncipio da Substituição de Liskov**, substituímos o **RegisterStudentToMySql** pela classe **RegisterStudentToFireStore** e o código funciona perfeitamente.
 
### Quarto Pedido
 
Devido a agilidade que você trocou o método de implementação, o cliente decidiu que agora ele quer que quando um aluno é registrado, seja enviado um email de boas vindas utilizando a **API do Gmail** assim que o cadastro do aluno terminar.
 
Pensando bastante, você decide que esse é um motivo para alterar a classe **RegisterStentImplementation**, já que será adicionado mais um passo ao registro, que é o envio do e-mail.
 
```Dart
abstract class SendEmail{
 Future<void> sendEmail(NewStudent newStudent);
}
 
class RegisterStentImplementation implements RegisterStudent {
 final RegisterStudent _registerStudent;
 final SendEmail _sendEmail;
  RegisterStentImplementation({required RegisterStudent registerStudent, required SendEmail sendEmail}):_registerStudent = registerStudent, _sendEmail = sendEmail;
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent) async{
   StudentRegistered studentRegistered = await _registerStudent.registerStudent(newStudent);
   await _sendEmail.sendEmail(newStudent);
   return studentRegistered;
 }
}
 
class SendEmailWithGmail implements SendEmail{
 @override
 Future<void> sendEmail(NewStudent newStudent) async {
     /*
       Os meios de enviar o e-mail com o gmail devem ser implementados aqui
     */
   print('Boas Vindas ${newStudent.name} enviado para ${newStudent.email} via Gmail');
 }
}
 
class RegisterStudentInjection implements RegisterStudent {
 final RegisterStentImplementation _registerStudent =
   RegisterStentImplementation(registerStudent: RegisterStudentToFireStore(),sendEmail: SendEmailWithGmail());
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent){
   return _registerStudent.registerStudent(newStudent);
 }
}
```
 
#### Quarta Análise
 
* **SendEmail:** Uma nova Interface para enviar e-mails. Para que possamos nos beneficiar de todas as vantagens do SOLID.
 
* **RegisterStentImplementation:** Nessa Implementação parece que estamos ferindo dois princípios o **O - Princípio do Aberto Fechado**, que fala que uma classe não deve ser modificada apenas extendida, e também o **S - Principio da Responsabilidade Única** em que uma classe só pode ter um único motivo para mudar. Entretanto isso não é verdade, tendo em vista que essa Classe implementa o passo a passo que deve ocorrer quando um novo aluno é registrado, e isso foi modificado pelo fato do cliente ter modificado a regra de negócio requerendo que um e-mail seja enviado no ato do aluno ser registrado.
 
* **SendEmailWithGmail:** A classe que vai conhecer como enviar um e-mail para um novo estudante utilizando o Gmail
 
* **RegisterStudentInjection:** Como a classe **RegisterStentImplementation** agora exige um **SendEmail** em seu construtor, ele deve ser adicionado aqui também na injeção das dependências.
 
### Quinta Pedido
 
O cliente relatou que alguns alunos perderam o acesso ao e-mail cadastrado, outros reclamaram que o nome deles estava escrito errado. Então ele gostaria de uma feature para poder ajustar no sistema
 
#### Quinta Implementação
 
```Dart
abstract class UpdateStudent{
 Future<StudentRegistered> updateStudent(StudentRegistered studentRegistered, NewStudent newStudent);
}
 
class UpdateStudentImplementation implements UpdateStudent {
 final UpdateStudent _updateStudent;
 UpdateStudentImplementation({required UpdateStudent updateStudent}):_updateStudent = updateStudent;
  @override
 Future<StudentRegistered> updateStudent(StudentRegistered studentRegistered, NewStudent newStudent){
   return _updateStudent.updateStudent(studentRegistered,newStudent);
}
}
 
class UpdatesToFireStore implements UpdateStudent { 
 @override
 Future<StudentRegistered> updateStudent(StudentRegistered oldStudent, NewStudent newStudent) async {
   /*
       Implementação da atualização dos dados no FireBase
   */
   print('O Estudante de Id:${oldStudent.id} teve o nome alterado para ${newStudent.name} e o e-mail alterado para ${newStudent.email}');
   return StudentRegistered(id: oldStudent.id, name: newStudent.name, email: newStudent.email);
 }
}
 
class Account implements RegisterStudent, UpdateStudent{
 
 final RegisterStudentImplementation _registerStudent = RegisterStudentImplementation(registerStudent: RegisterStudentToFireStore(),sendEmail: SendEmailWithGmail());
 final UpdateStudentImplementation _updateStudent = UpdateStudentImplementation(updateStudent: UpdatesToFireStore());
  @override
 Future<StudentRegistered> registerStudent(NewStudent newStudent){
   return _registerStudent.registerStudent(newStudent);
 }
  @override
 Future<StudentRegistered> updateStudent(StudentRegistered studentRegistered, NewStudent newStudent){
   return _updateStudent.updateStudent(studentRegistered,newStudent);
 }
}
 
main() async {
 StudentRegistered studentRegistered = await Account().registerStudent(NewStudent(name:'Camilo',email:'camilo.coelho.gomes@gmail.com'));
 Account().updateStudent(studentRegistered,NewStudent(name:'Camilo Coelho',email:'camilo.coelho@hotmail.com'));
}
```
 
#### Quinta Análise
 
* **UpdateStudent:** Cria-se mais uma interface para atualizar o que os estudantes selecionaram, quando faz isso respeita-se dois princípios o **S - Principio da Responsabilidade Única** e um que ainda não abordamos o **I - Princípio da Segregação de Interface (Interface Segregation Principle)**, que diz que uma classe não deve ser obrigada a implementar uma interface que ela não precisa.
 
* **UpdateStudentImplementation:** Implementação da UpdateStutend por meio da injeção de dependências, como fizemos com **RegisterStudentImplementation**, com o objetivo de seguir o mesmo princípio.
 
* **UpdatesToFireStore:** Mesmo princípio do **RegisterStudentToFireStore**, ela é a única classe que sabe como essa regra de negócio será executada.
 
* **Account:** A classe **RegisterStudentInjection** foi renomeado para a **Account** já que semanticamente ela que irá ser chamada ao lidar com todos os dados dos alunos, tanto o registro de novos alunos quanto a atualização, e para que o **I - Princípio da Segregação de Interface** seja cumprido, ela implementa tanto a classe abstrata **RegisterStudent**, quanto a **UpdateStudent**.
 
* **main:** Essa Função está simplesmente chamando os dois métodos da classe account para tanto o registro, quanto a atualização dos dados do recém registrado
 
## Disposição dos Cômodos
 
> *"Bons arquitetos separam cuidadosamente os detalhes da política e, então, desacoplam as políticas dos detalhes tão completamente que a política passa a não ter nenhum conhecimento dos detalhes e a não depender dos detalhes de maneira nenhuma"* - Escrito por Uncle Bob no livro Arquitetura Limpa.
 
Quando todos os princípios do SOLID são cuidadosamente seguidos e pensados, construir algo assim se torna mais fácil.
 
<img src='https://miro.medium.com/max/1400/1*B4LEEv0PbmqvYolUH-mCzw.png'>
 
### Políticas
 
As políticas tratam de implementar aquilo que o software deve fazer, o que traz valor para quem o utiliza. É o que no fim irá fazer com que o projeto fature.
Elas são independentes de frameworks, de banco de dados, apis externas, e como tal, não devem conhecer esses itens.
Normalmente são divididas em duas categorias as **Entidades** e os **Casos de Uso**.
 
#### Entidades
 
As Entidades são itens e classes que representam regras de negócio que também serão feitas no mundo real e que nós só estamos trazendo para o nosso software, no nosso exemplo acima cairia nas entidades as classes:
 
* **NewStudent**
* **StudentRegistered**
* **RegisterStudent**
* **UpdateStudent**
* **SendEmail**
 
Elas são regras de negócio que antes do nosso software eram feitas mesmo que com um arquivo de papel, mesmo o **SendEmail** entra aqui, já que o mesmo pode ser enviado utilizando uma escrita de e-mail normal
 
Para que uma arquitetura seja limpa, uma Entidade deve conhecer apenas outras entidades.
 
#### Casos de Uso
 
São regras de negócio que podem ser implementadas graças ao nosso software, eles podem conhecer e depender apenas de Entidades, no nosso código temos os seguintes casos de uso:
 
* **RegisterStudentImplementation**
* **UpdateStudentImplementation**
 
Nossos casos de uso conseguem criar um registro no banco de dados, enviar um email para o usuário no exato momento que isso acontece, internamente eles só conhecem entidades.
 
### Detalhes
 
Os detalhes são todos restantes, sendo desde o local que essa informação é exibida pelo usuário, como se fosse um sistema web, um app mobile, um app local, Como também o banco de dados, ou um serviço de envio de e-mail, ou qualquer api externa.
 
Todos os detalhes devem ser implementados a partir de alguma **Política** para que o mesmo possa se comunicar com outras Políticas do Software.
 
#### UI
 
Os métodos que irão servir às regras de negócio, no nosso software ela está representado pela função:
 
* **main**
 
#### Banco de dados
 
A prova de que o banco de dados está desacoplado é que nosso cliente pediu para que o mesmo fosse modificado para no meio do projeto, mas como ambos implementam alguma Entidade da nossa regra de negócio elas puderam ser facilmente substituídos, representado pelos:
 
* **RegisterStudentToMySql**
* **RegisterStudentToFireStore**
* **UpdatesToFireStore**
 
#### Serviços em Geral
 
Qualquer outro serviço que a regra de negócio venha precisar, nesse caso o serviço de envio de e-mail representado pelo:
 
* **SendEmailWithGmail**
 
## Adaptadores de Interface
 
Para finalizar, temos nosso elo de ligação, uma única classe que conhece os Casos de Usos e os Detalhes. Eles faz todo o controle de injeção de dependência para falar quais Detalhes serão utilizados por quais Políticas. Representado pelo:
 
* **Account**
 
