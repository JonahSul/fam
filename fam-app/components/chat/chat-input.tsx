import React, { useState } from 'react';
import { StyleSheet, TextInput, TouchableOpacity } from 'react-native';
import { IconSymbol } from '../ui/icon-symbol';
import { ThemedView } from '../themed-view';

interface ChatInputProps {
  onSend: (message: string) => void;
  placeholder?: string;
}

export function ChatInput({ onSend, placeholder = 'Type a message...' }: ChatInputProps) {
  const [message, setMessage] = useState('');

  const handleSend = () => {
    if (message.trim()) {
      onSend(message.trim());
      setMessage('');
    }
  };

  return (
    <ThemedView style={styles.container}>
            <TextInput
        style={[styles.input, { maxHeight: 100 }]}
        value={message}
        onChangeText={setMessage}
        placeholder={placeholder}
        placeholderTextColor="#999"
        multiline
      />
      <TouchableOpacity
        onPress={handleSend}
        style={[styles.sendButton, !message.trim() && styles.sendButtonDisabled]}
        disabled={!message.trim()}
      >
        <IconSymbol
          name="paperplane.fill"
          size={24}
          color={message.trim() ? '#0084ff' : '#999'}
        />
      </TouchableOpacity>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 8,
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: '#ccc',
  },
  input: {
    flex: 1,
    minHeight: 40,
    maxHeight: 100,
    marginRight: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    backgroundColor: '#f8f9fa',
    borderRadius: 20,
    color: '#000',
  },
  sendButton: {
    width: 40,
    height: 40,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sendButtonDisabled: {
    opacity: 0.5,
  },
});