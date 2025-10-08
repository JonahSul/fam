import React from 'react';
import { View, StyleSheet } from 'react-native';
import { ThemedText } from '../themed-text';
import { ThemedView } from '../themed-view';

interface MessageBubbleProps {
  message: string;
  isUser: boolean;
  timestamp?: Date;
}

export function MessageBubble({ message, isUser, timestamp }: MessageBubbleProps) {
  return (
    <View style={[styles.container, isUser ? styles.userContainer : styles.agentContainer]}>
      <ThemedView style={[styles.bubble, isUser ? styles.userBubble : styles.agentBubble]}>
        <ThemedText>{message}</ThemedText>
        {timestamp && (
          <ThemedText style={styles.timestamp}>
            {timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </ThemedText>
        )}
      </ThemedView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 8,
    marginVertical: 4,
    flexDirection: 'row',
  },
  userContainer: {
    justifyContent: 'flex-end',
  },
  agentContainer: {
    justifyContent: 'flex-start',
  },
  bubble: {
    maxWidth: '80%',
    padding: 12,
    borderRadius: 16,
  },
  userBubble: {
    backgroundColor: '#0084ff',
    borderBottomRightRadius: 4,
  },
  agentBubble: {
    backgroundColor: '#e9ecef',
    borderBottomLeftRadius: 4,
  },
  timestamp: {
    fontSize: 10,
    marginTop: 4,
    opacity: 0.7,
  },
});