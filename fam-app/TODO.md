# Todo List

- [ ] **Set up Firebase Authentication**
  - [ ] Configure email/password or Google Sign-In in the Firebase console.
  - [ ] Create a login/registration screen in the React Native app.
  - [ ] Implement logic to handle user sign-up, sign-in, and sign-out.
  - [ ] Protect routes so that only authenticated users can access the chat screen.

- [ ] **Build the Chat UI**
  - [ ] Create a new screen component for the chat interface.
  - [ ] Use a library like `react-native-gifted-chat` to quickly build a standard chat UI.
  - [ ] Add a text input for the user to type messages and a send button.
  - [ ] Display the conversation history in a scrollable view.

- [ ] **Integrate Genkit Agent**
  - [ ] Create a Firebase Callable Function that invokes the `menuSuggestionFlow`.
  - [ ] Call this function from the React Native app when the user sends a message.
  - [ ] Display the agent's response in the chat UI.

- [ ] **Implement Real-time State Management (Backend)**
  - [ ] Set up a WebSocket server (e.g., using Node.js with `ws` or `socket.io`).
  - [ ] Define WebSocket events for real-time communication (e.g., `newMessage`, `agentResponse`).
  - [ ] Connect the Firebase Function to the WebSocket server to push agent responses in real-time.

- [ ] **Implement Real-time State Management (Frontend)**
  - [ ] Connect the React Native app to the WebSocket server.
  - [ ] Listen for incoming messages and update the chat UI in real-time.
  - [ ] Send user messages over the WebSocket connection.

- [ ] **Styling and UX**
  - [ ] Apply a consistent theme to the app using the `constants/theme.ts` file.
  - [ ] Add loading indicators and error messages.
  - [ ] Ensure the app is responsive and works well on both iOS and Android.
