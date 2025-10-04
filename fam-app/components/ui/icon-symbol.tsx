/**
 * Icon Symbol Component
 * Simple icon component using SF Symbols names
 */

import { StyleSheet, Text, TextProps } from 'react-native';

export interface IconSymbolProps extends TextProps {
  name: string;
  size?: number;
  color?: string;
}

export function IconSymbol({ name, size = 24, color = '#000', style, ...rest }: IconSymbolProps) {
  // Simple icon mapping - in a real app you'd use a proper icon library
  const iconMap: Record<string, string> = {
    'paperplane.fill': '✈',
    'bubble.left.fill': '💬',
    'person.circle': '👤',
    'gear': '⚙',
  };

  return (
    <Text
      style={[styles.icon, { fontSize: size, color }, style]}
      {...rest}
    >
      {iconMap[name] || '•'}
    </Text>
  );
}

const styles = StyleSheet.create({
  icon: {
    textAlign: 'center',
  },
});
