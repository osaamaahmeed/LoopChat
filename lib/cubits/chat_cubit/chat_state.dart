part of 'chat_cubit.dart';


abstract class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatSuccess extends ChatState {}

/* To DO:
1. create a way of showing if a message is sent to the server
2. creata a way to know if I am online or offline
3. creata a way to save the previous messages locally and delete it also after 24h

*/ 
