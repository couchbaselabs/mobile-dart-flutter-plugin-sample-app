import 'dart:async';

import 'package:cbl_flutter_multiplatform/cbl_flutter_multiplatform.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage(
      {required this.channel,
      required this.username,
      required this.password,
      super.key});

  final String channel;
  final String username;
  final String password;

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  late Database database;
  late Collection chatMessages;
  late Replicator replicator;
  late ChatMessageRepository chatMessageRepository;
  late ListenerToken token;

  Future<ChatMessageRepository> setup() async {
    // Req 13
    database = await Database.openAsync(widget.channel);

    // Req 12
    // await Database.exists('name');
    
    // Req 17
    //Database.copy(from: 'from', name: 'name');

    // Req 5 
    // await database.delete();

    // Req 7
    final query = await Query.fromN1ql(database,
    r'''
    SELECT *, META().id AS docId
    FROM _
    WHERE type = 'chatMessage'
    ''',);

    // Req 8
    query.setParameters(Parameters({'type': 'chatMessage'}));

    query.execute();


    // Req 4 
    // database.performMaintenance(MaintenanceType.compact);

    // Req 19
    Database.log.console.level = LogLevel.verbose;

    Database.log.file.config = LogFileConfiguration(
      directory: 'logs',
      maxRotateCount: 10,
      maxSize: 10 * 1024 * 1024,
    );

    // Req 16
    // It just releases the thread for other operations while it waits for something (such as IO or DB) to finish.
    //database = await Database.openAsync(widget.channel);

    // Req 15
    chatMessages = await database.createCollection('message', 'chat');

    // Req 9
    // This index speeds up queries, among others, that filter documents by an
    // exact `type` and sort by `createdAt`.
    await chatMessages.createIndex(
      'type+createdAt',
      ValueIndex([
        ValueIndexItem.property('type'),
        ValueIndexItem.property('createdAt'),
      ]),
    );

    // Req 10

    // Get specific document
    //chatMessages.document('');

    // Req 2
    chatMessages.documentChanges('').listen((change) {
      print('Document change: ${change.collection.count}');
    });

    // update this with your device ip
    final targetURL = Uri.parse('ws://192.168.0.116:4984/examplechat');

    final targetEndpoint = UrlEndpoint(targetURL);

    // Req 20
    final config = ReplicatorConfiguration(target: targetEndpoint);

    config.replicatorType = ReplicatorType.pushAndPull;

    config.enableAutoPurge = false;

    config.continuous = true;

    config.authenticator = BasicAuthenticator(
        username: widget.username, password: widget.password);

    // Req 1
    final conflict = ConflictResolver.from((conflict) =>  conflict.remoteDocument);

    config.addCollection(
        chatMessages, CollectionConfiguration(channels: [widget.channel], conflictResolver: conflict));

    replicator = await Replicator.create(config);

    // Req 28
    // await replicator.status;

    // Req 22
    // replicator = await Replicator.createAsync(config);
    
    // Req 21
    // replicator = await Replicator.createSync(config);

    // This is an alternative stream based API for the [addChangeListener] API.
    // replicator.changes().listen((change) {
    //   if (change.status.activity == ReplicatorActivityLevel.stopped) {
    //     print('Replication stopped');
    //   } else {
    //     print('Replicator is currently: ${change.status.activity.name}');
    //   }
    // });
    
   token = await replicator.addChangeListener((change) {
    
      if (change.status.activity == ReplicatorActivityLevel.stopped) {
        print('Replication stopped');
      } else {
        print('Replicator is currently: ${change.status.activity.name}');
      }
    });

    // Req 25
    await replicator.start();

    // Req 11
    // await database.close();

    chatMessageRepository = ChatMessageRepository(database, chatMessages, widget.channel);

    return chatMessageRepository;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ChatMessageRepository>(
          future: setup(),
          builder: (context, snapshot) => snapshot.data == null
              ? const Center(child: CircularProgressIndicator())
              : ChatMessagesPageMobile(
                  channel: widget.channel,
                  repository: snapshot.data,
                  replicator: replicator,
                  token: token,
                )),
    );
  }
}

class ChatMessagesPageMobile extends StatefulWidget {
  const ChatMessagesPageMobile(
      {required this.channel, this.repository, this.replicator, this.token, super.key});
  final ChatMessageRepository? repository;
  final String channel;
  final Replicator? replicator;
  final ListenerToken? token;

  @override
  State<ChatMessagesPageMobile> createState() => _ChatMessagesPageMobileState();
}

class _ChatMessagesPageMobileState extends State<ChatMessagesPageMobile> {
  List<ChatMessage> _chatMessages = [];
  late StreamSubscription _chatMessagesSub;

  @override
  void initState() {
    super.initState();

    _chatMessagesSub =
        widget.repository!.allChatMessagesStream().listen((chatMessages) {
      setState(() => _chatMessages = chatMessages);
    });
  }

  @override
  void dispose() {
    _chatMessagesSub.cancel();

    // Req 26
    widget.replicator?.stop();
    
    // Req 24
    widget.replicator?.removeChangeListener(widget.token!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.channel),
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final chatMessage =
                      _chatMessages[_chatMessages.length - 1 - index];
                  return ChatMessageTile(chatMessage: chatMessage);
                },
              ),
            ),
            const Divider(height: 0),
            _ChatMessageForm(onSubmit: widget.repository!.createChatMessage)
          ]),
        ),
      );
}

class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({super.key, required this.chatMessage});
  final ChatMessage chatMessage;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          onTap: () {
            
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMd().add_jm().format(chatMessage.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 5),
              Text(chatMessage.chatMessage.toString())
            ],
          ),
        ),
      );
}

class _ChatMessageForm extends StatefulWidget {
  const _ChatMessageForm({required this.onSubmit});
  final ValueChanged<String> onSubmit;
  @override
  _ChatMessageFormState createState() => _ChatMessageFormState();
}

class _ChatMessageFormState extends State<_ChatMessageForm> {
  late final TextEditingController _messageController;
  late final FocusNode _messageFocusNode;
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    widget.onSubmit(message);
    _messageController.clear();
    _messageFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration:
                    const InputDecoration.collapsed(hintText: 'Message'),
                autofocus: true,
                focusNode: _messageFocusNode,
                controller: _messageController,
                minLines: 1,
                maxLines: 10,
                style: Theme.of(context).textTheme.bodyMedium,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 5),
            TextButton(
              onPressed: _onSubmit,
              child: const Text('Send'),
            )
          ],
        ),
      );
}

abstract class ChatMessage {
  String get id;
  String get chatMessage;
  DateTime get createdAt;
}

class CblChatMessage extends ChatMessage {
  CblChatMessage(this.dict);
  final DictionaryInterface dict;
  @override
  String get id => dict.documentId;
  @override
  DateTime get createdAt => dict.value('createdAt')!;
  @override
  String get chatMessage => dict.value('chatMessage') ?? '-';
}

extension DictionaryDocumentIdExt on DictionaryInterface {
  String get documentId {
    final self = this;
    return self is Document ? self.id : self.value('id')!;
  }
}

class ChatMessageRepository {
  ChatMessageRepository(this.database, this.collection, this.channel);
  final Database database;
  final Collection collection;
  final String channel;

  Future<ChatMessage> createChatMessage(String message) async {
    final doc = MutableDocument({
      'type': 'chatMessage',
      'createdAt': DateTime.now(),
      'userId': channel,
      'chatMessage': message,
    });

    // Req 3
    await collection.saveDocument(doc);
    return CblChatMessage(doc);
  }

  Stream<List<ChatMessage>> allChatMessagesStream() {
    // Req 6
    final query = const QueryBuilder()
        .select(
          SelectResult.expression(Meta.id),
          SelectResult.property('createdAt'),
          SelectResult.property('chatMessage'),
        )
        .from(DataSource.collection(collection))
        .where(
          Expression.property('type').equalTo(Expression.value('chatMessage')),
        )
        .orderBy(Ordering.property('createdAt'));

    return query.changes().asyncMap(
          (change) => change.results
              .asStream()
              .map((result) => CblChatMessage(result))
              .toList(),
        );
  }
}
