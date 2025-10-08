import React from 'react';
import { FlatList, StyleSheet, ListRenderItemInfo } from 'react-native';
import { MessageBubble } from './message-bubble';

export interface ChatMessage {
  id: string;
  text: string;
  isUser: boolean;
  timestamp: Date;
}

interface MessageListProps {
  messages: ChatMessage[];
  onEndReached?: () => void;
}

export function MessageList({ messages, onEndReached }: MessageListProps) {
  const renderItem = ({ item }: ListRenderItemInfo<ChatMessage>) => (
    <MessageBubble
      message={item.text}
      isUser={item.isUser}
      timestamp={item.timestamp}
    />
  );

  return (
    <FlatList
      data={messages}
      renderItem={renderItem}
      keyExtractor={(item) => item.id}
      onEndReached={onEndReached}
      onEndReachedThreshold={0.5}
      inverted
      contentContainerStyle={styles.contentContainer}
      style={styles.container}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  contentContainer: {
    paddingVertical: 16,
  },
});