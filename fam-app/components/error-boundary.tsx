/**
 * Error Boundary Component
 * Catches and handles React errors gracefully
 */

import React, { Component, ErrorInfo, ReactNode } from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { ThemedText } from './themed-text';
import { ThemedView } from './themed-view';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    
    // You can log the error to an error reporting service here
    // Example: Sentry.captureException(error);
  }

  handleReset = () => {
    this.setState({ hasError: false, error: undefined });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <ThemedView style={styles.container}>
          <View style={styles.content}>
            <ThemedText style={styles.title}>Oops!</ThemedText>
            <ThemedText style={styles.message}>
              Something went wrong. We've been notified and are working on it.
            </ThemedText>
            
            {__DEV__ && this.state.error && (
              <View style={styles.errorDetails}>
                <ThemedText style={styles.errorTitle}>Error Details:</ThemedText>
                <ThemedText style={styles.errorMessage}>
                  {this.state.error.message}
                </ThemedText>
                <ThemedText style={styles.errorStack}>
                  {this.state.error.stack}
                </ThemedText>
              </View>
            )}

            <TouchableOpacity style={styles.button} onPress={this.handleReset}>
              <ThemedText style={styles.buttonText}>Try Again</ThemedText>
            </TouchableOpacity>
          </View>
        </ThemedView>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  content: {
    maxWidth: 400,
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#dc3545',
  },
  message: {
    fontSize: 16,
    textAlign: 'center',
    marginBottom: 32,
    opacity: 0.8,
  },
  errorDetails: {
    width: '100%',
    padding: 16,
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    marginBottom: 24,
  },
  errorTitle: {
    fontSize: 14,
    fontWeight: '600',
    marginBottom: 8,
  },
  errorMessage: {
    fontSize: 12,
    color: '#dc3545',
    marginBottom: 8,
  },
  errorStack: {
    fontSize: 10,
    opacity: 0.6,
    fontFamily: Platform.select({ ios: 'Courier', android: 'monospace' }),
  },
  button: {
    paddingHorizontal: 32,
    paddingVertical: 12,
    backgroundColor: '#0084ff',
    borderRadius: 8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
