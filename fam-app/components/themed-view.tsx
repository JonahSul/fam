/**
 * Themed View Component
 * Simple view component with theme support
 */

import { View, ViewProps, StyleSheet } from 'react-native';

export type ThemedViewProps = ViewProps;

export function ThemedView({ style, ...rest }: ThemedViewProps) {
  return <View style={[styles.view, style]} {...rest} />;
}

const styles = StyleSheet.create({
  view: {
    backgroundColor: '#fff',
  },
});
