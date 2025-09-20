import React, { useCallback } from 'react';
import { StyleSheet, KeyboardAvoidingView, Platform, ActivityIndicator } from 'react-native';
import { ThemedView } from '@/components/themed-view';
import { MessageList, ChatInput } from '@/components/chat';
import { getFunctions, httpsCallable } from 'firebase/functions';
import { app } from '@/firebase';
import { useMessages } from '@/hooks/use-messages';

export default function ChatScreen() {
  const { messages, loading } = useMessages();
  const functions = getFunctions(app);
  const handleChatMessage = httpsCallable(functions, 'handleChatMessage');

  const handleSend = useCallback(async (text: string) => {
    try {
      // The message will be added to Firestore by the cloud function
      await handleChatMessage(text);
    } catch (error) {
      console.error('Error sending message:', error);
      // You might want to show an error message to the user here
    }
  }, [handleChatMessage]);

  return (
    <KeyboardAvoidingView 
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      style={styles.container}
    >
      <ThemedView style={styles.container}>
        {loading ? (
          <ActivityIndicator style={styles.loader} />
        ) : (
          <MessageList messages={messages} />
        )}
        <ChatInput onSend={handleSend} />
      </ThemedView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loader: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});