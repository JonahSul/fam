/**
 * Tabs Layout
 * Main app layout with bottom tabs
 */

import { Tabs } from 'expo-router';
import { IconSymbol } from '@/components/ui/icon-symbol';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: true,
        tabBarActiveTintColor: '#0084ff',
      }}
    >
      <Tabs.Screen
        name="chat"
        options={{
          title: 'Chat',
          tabBarIcon: ({ color }) => <IconSymbol name="bubble.left.fill" color={color} />,
          headerTitle: 'FAM Assistant',
        }}
      />
    </Tabs>
  );
}
