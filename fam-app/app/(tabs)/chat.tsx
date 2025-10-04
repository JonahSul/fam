import React, { useCallback } from 'react';
import { StyleSheet, KeyboardAvoidingView, Platform, ActivityIndicator, View } from 'react-native';
import { ThemedView } from '@/components/themed-view';
import { ThemedText } from '@/components/themed-text';
import { MessageList, ChatInput } from '@/components/chat';
import { httpsCallable } from 'firebase/functions';
import { functions } from '@/firebase';
import { useMessages } from '@/hooks/use-messages';

export default function ChatScreen() {
  const { messages, loading, error } = useMessages();
  const handleChatMessage = httpsCallable(functions, 'handleChatMessage');

  const handleSend = useCallback(async (text: string) => {
    try {
      // The message will be added to Firestore by the cloud function
      await handleChatMessage({ message: text });
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
          <View style={styles.centerContent}>
            <ActivityIndicator size="large" color="#0084ff" />
            <ThemedText style={styles.loadingText}>Loading messages...</ThemedText>
          </View>
        ) : error ? (
          <View style={styles.centerContent}>
            <ThemedText style={styles.errorText}>Error loading messages</ThemedText>
            <ThemedText style={styles.errorSubtext}>{error}</ThemedText>
          </View>
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
  centerContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  loadingText: {
    marginTop: 12,
    opacity: 0.7,
  },
  errorText: {
    color: '#dc3545',
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
  },
  errorSubtext: {
    opacity: 0.7,
    textAlign: 'center',
  },
});