import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/components/chat_bubble.dart';
import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/components/loading_dialog.dart';
import 'package:edubot/components/secondary_text_field.dart';
import 'package:edubot/main.dart';
import 'package:edubot/pages/chat_history_page.dart';
import 'package:edubot/pages/settings_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:edubot/services/firebase/firebase_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Get the required controllers
  final TextEditingController _userInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Message> _previousMessages;

  bool _conversationHasLoaded = false; // Prevent multiple loads
  bool _isLoading = false; // Loading state
  bool _isSendEnabled = false; // Icon button enabled state
  bool _isInputEnabled = true; // Text field enabled state

  // File manangement variables
  String? _selectedFileName;
  String? _selectedFilePath;
  String? _selectedFileType;
  String? _selectedFileExtension;
  int? _selectedFileSize;
  Uint8List? _selectedFileBytes; // Web only (testing)

  // Scroll to the bottom of the conversation upon inital chat page load
  void waitForMessagesThenScroll(ChatProvider chatProvider) async {
    // Wait for messages to load
    while (chatProvider.messages.isEmpty) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    // Wait for build/layout
    await Future.delayed(Duration(milliseconds: 100));

    // Wait until scroll metrics stabilize
    double previousExtent = -1;
    int retries = 10;

    while (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent != previousExtent &&
        retries > 0) {
      previousExtent = _scrollController.position.maxScrollExtent;
      await Future.delayed(Duration(milliseconds: 50));
      retries--;
    }

    // Final scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void handleInputChange() {
    // Enable send button if there is text in the input field
    if (!_isLoading && _isSendEnabled != _userInputController.text.isNotEmpty) {
      setState(() {
        _isSendEnabled = _userInputController.text.isNotEmpty;
      });
    }
  }

  // Load message
  Future<void> loadMessages() async {
    // After widget tree is built, show loading circle with global context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, _, __) => const Center(child: LoadingDialog()),
        ),
      );
    });

    // Try load message from Firestore using the global context
    try {
      await Provider.of<FirebaseProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).loadMessagesFromFirestore();
    } finally {
      // Safely close dialog
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }
    }
  }

  // Select file method
  Future<void> pickFile() async {
    // Get the file from the platform and store in result - only allow document-related extensions (eg. 'pdf')
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'], // Removed '.doc' support as it doesn't work with linux
    );

    // Check that file picked is not null
    if (result != null && result.files.single.path != null) {
      // Assign the result to a fileName and extension to fileType
      String fileName = result.files.single.name;
      String filePath = result.files.single.path!;

      // Get MIME type using 'mime' package
      String? mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

      setState(() {
        // Assign to the selected variables
        _selectedFileName = fileName;
        _selectedFileType = mimeType;
        _selectedFilePath = filePath;

        // Assign the input text field to a default value and disable it (since the user prompt doesn't get passed anyway)
        _userInputController.text = 'Summarise this text';
        _isInputEnabled = false;
      });

      // Read bytes on all platforms
      Uint8List? fileBytes;

      // If the platform is web, assign the file bytes, else also assign and read them using dart.io
      if (kIsWeb) {
        fileBytes = result.files.single.bytes!;
      } else {
        // Read the file into bytes manually
        File file = File(filePath);
        fileBytes = await file.readAsBytes();
      }

      // Get the length of the file bytes
      int fileSize = fileBytes.lengthInBytes;

      setState(() {
        // Update _selectedFileBytes and _selectedFileSize
        _selectedFileBytes = fileBytes;
        _selectedFileSize = fileSize;
      });
    }
  }

  // Start new conversation
  Future<void> startNewConversation(BuildContext context) async {
    // Get instance of auth & firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    AuthManager authManager = AuthManager();

    // Get ChatProvider to access the current list of messages
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Get FirebaseProvider to access Firestore methods
    final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);

    // Establish a context for navigating and snack bar management
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Remove any snackbars if present
    scaffoldMessenger.removeCurrentSnackBar();

    // Show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.blue));
      },
    );

    // Get conversationId from Firestore if it exists
    String? conversationId = await firebaseProvider.getSavedConversationId();

    // Allocate an empty document in 'Conversations' to store chats
    final hasContent = chatProvider.messages.any(
      (m) => !m.isUser && m.content.trim().isNotEmpty,
    );

    if (conversationId != null && hasContent) {
      final doc = await firestore
          .collection("Users")
          .doc(authManager.getCurrentUser()?.uid)
          .collection('Conversations')
          .add(({}));

      // Assign conversationId to the new conversation ID
      conversationId = doc.id;

      // Save as activeConversationId
      firestore
          .collection("Users")
          .doc(authManager.getCurrentUser()?.uid)
          .update({'activeConversationId': conversationId});

      // Clear messages
      setState(() {
        chatProvider.messages.clear();
      });

      // Notify the user where the previous conversation
      showSnackbar(
        scaffoldMessenger,
        "See Chat History for previous conversation",
        Icon(Icons.info, color: Colors.blue),
        true,
      );
    } else {
      // If new conversation already started, notify the user
      showSnackbar(
        scaffoldMessenger,
        "New conversation already started",
        Icon(Icons.warning, color: Colors.amberAccent.shade700),
        true,
      );
    }
    

    navigator.pop(); // Dismiss loading circle
  }

  @override
  void initState() {
    super.initState();
    _userInputController.addListener(
      handleInputChange,
    ); // Listen for changes in the input field

    final chatProvider = Provider.of<ChatProvider>(
      context,
      listen: false,
    ); // Get ChatProvider

    Future.microtask(() {
      // Start asyncronous task where the system wait for messages to load then scrolls to bottom
      waitForMessagesThenScroll(chatProvider);
    });
  }

  @override
  void dispose() {
    // Remove listener and dispose of the controller
    _userInputController.removeListener(handleInputChange);
    _userInputController.dispose();
    super.dispose();
  }

  // Only run this state when a dependency has changed
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialise previous messages
    _previousMessages = [];

    // Once dependency is changed, communicate with ChatProvider to load messages from Firestore (only do this once)
    if (!_conversationHasLoaded) {
      loadMessages();
      _conversationHasLoaded = true;
    }
  }

  // Get the user's first name in their display name
  String? getFirstName() {
    final AuthManager authManager = AuthManager();

    final fullName = authManager.getCurrentUser()?.displayName;
    final firstName = fullName.toString().split(" ")[0];

    return firstName;
  }

  // Send a response to ChatProvider
  void sendMessage() async {
    final chatProvider = context.read<ChatProvider>();

    setState(() {
      _isSendEnabled = false; // Disable send button while sending
      _isLoading = true; // Show loading state
    });

    // Prevent empty sends
    if (_userInputController.text.trim().isNotEmpty) {
      final message = _userInputController.text.trim();
      _userInputController.clear();

      // If the user did not send a file name, send a regular message,
      // else if selectedFileBytes is not null, process the file contents and return a summary
      if (_selectedFileName == null) {
        // Trigger title generation in the background
        await chatProvider.sendStream(message);
      } else if (_selectedFileName != null && _selectedFileBytes != null) {
        final fileName = _selectedFileName;
        setState(() {
          _selectedFileName = null;
          _isInputEnabled = true;
        });
        await chatProvider.sendFile(
          fileName!,
          _selectedFileType ?? 'application/octet-stream',
          _selectedFilePath ?? '',
          _selectedFileBytes!,
          _selectedFileSize!,
        );
      }
    }

    if (!mounted) return; // Ensure widget state is mounted

    setState(() {
      _isLoading = false; // Hide loading state
      // Determine if the send button should be enabled based on the input field state
      if (_userInputController.text.isEmpty) {
        _isSendEnabled = false;
      } else {
        _isSendEnabled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          "EduBot",
          style: TextStyle(
            fontFamily: "Nunito",
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        // Navigation actions
        actions: [
          // New conversation
          IconButton(
            icon: Icon(
              Icons.loupe,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => startNewConversation(context),
          ),

          // History
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
              weight: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatHistoryPage()),
              );
            },
          ),

          // Settings
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),

      // Chat container
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  // Scroll to most recent message sent if the message count has changed
                  // chatProvider.loadMessagesFromFirestore();
                  if (_previousMessages.length !=
                      chatProvider.messages.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                    // Add a copy of the messages to the previous messages
                    _previousMessages = List.from(chatProvider.messages);
                  }

                  // If empty, display welcome message
                  if (chatProvider.messages.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome, ${getFirstName()}",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Start typing to get started",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    );
                  }

                  // Return a list of messages from ChatProvider, both from roles 'user' and 'assistant'
                  return ListView.builder(
                    controller:
                        _scrollController, // Assign the scroll controller
                    // Add an additonal message onto the chat provider messages count if loading
                    itemCount:
                        chatProvider.messages.length +
                        (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // If this is the last item we are loading, show the loading bubble
                      if (chatProvider.isLoading &&
                          index == chatProvider.messages.length) {
                        return ChatBubble(
                          message: Message(
                            content:
                                chatProvider.messages.last.messageType ==
                                        MessageType.text
                                    ? "Loading..."
                                    : "Processing File...",
                            isUser: false,
                            timeStamp: DateTime.now(),
                          ),
                          isLoading: true,
                        );
                      }

                      // Get each message
                      final message = chatProvider.messages[index];

                      // Skip messsages with file type "fileContent"
                      if (message.messageType == MessageType.fileContent) {
                        return const SizedBox.shrink(); // Acts like continue
                      }

                      // If the message sent by the user is a file, set the file extension
                      if (message.messageType == MessageType.text) {
                        return ChatBubble(message: message);
                      } else {
                        return ChatBubble(
                          message: message,
                          fileExtension: _selectedFileExtension,
                          fileSize: message.fileSize,
                        );
                      }
                    },
                  );
                },
              ),
            ),

            // User input box + file preview
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              // Column with both file container and input row
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Only display file container if _selectedFileName is not null
                  if (_selectedFileName != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Color(0xFF364B55)
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),

                        // File box
                        child: Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Color(0xFF96C0CA)
                                      : Colors.blueGrey,
                            ),

                            SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                _selectedFileName!,
                                style: TextStyle(
                                  fontFamily: "Nunito",
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 24,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedFileName = null;
                                  _userInputController.text = "";
                                  _isInputEnabled = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Input row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Attach file button
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: IconButton(
                          onPressed: pickFile,
                          icon: Icon(
                            Icons.file_upload_outlined,
                            size: 24,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Color(0xFFECF6F9)
                                    : Color(0xFF074F67),
                          ),
                        ),
                      ),

                      // User input field
                      Expanded(
                        child: SecondaryTextField(
                          controller: _userInputController,
                          enabled: _isInputEnabled,
                        ),
                      ),

                      // Send message button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                _isSendEnabled
                                    ? Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Color(0xFF99DAE6)
                                        : Color(0xFF2B656B)
                                    : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Color(0xFF99DAE6).withValues(alpha: 0.75)
                                    : Color(0xFF2B656B).withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: IconButton(
                            onPressed: _isSendEnabled ? sendMessage : null,
                            icon: Icon(Icons.send, size: 24,),
                            disabledColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryFixed
                                .withValues(alpha: 0.75),
                            color:
                                Theme.of(context).colorScheme.onSecondaryFixed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
