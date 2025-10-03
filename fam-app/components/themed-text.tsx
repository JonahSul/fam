/**
 * Themed Text Component
 * Simple text component with theme support
 */

import { Text, TextProps, StyleSheet } from 'react-native';

export type ThemedTextProps = TextProps;

export function ThemedText({ style, ...rest }: ThemedTextProps) {
  return <Text style={[styles.text, style]} {...rest} />;
}

const styles = StyleSheet.create({
  text: {
    color: '#000',
  },
});
