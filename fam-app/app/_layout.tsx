/**
 * Root Layout
 * Handles authentication state and navigation setup
 */

import { useEffect } from 'react';
import { Stack, router, useSegments } from 'expo-router';
import { useAuth } from '@/hooks/use-auth';

export default function RootLayout() {
  const { user, loading } = useAuth();
  const segments = useSegments();

  useEffect(() => {
    if (loading) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (!user && !inAuthGroup) {
      // Redirect to login if not authenticated
      router.replace('/(auth)/login');
    } else if (user && inAuthGroup) {
      // Redirect to app if authenticated and trying to access auth screens
      router.replace('/(tabs)/chat');
    }
  }, [user, loading, segments]);

  return (
    <Stack screenOptions={{ headerShown: false }}>
      <Stack.Screen name="(auth)" options={{ headerShown: false }} />
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
    </Stack>
  );
}
