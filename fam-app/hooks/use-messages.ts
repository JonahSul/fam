import { useEffect, useState } from 'react';
import { getFirestore, collection, query, orderBy, onSnapshot } from 'firebase/firestore';
import { app } from '@/firebase';
import type { ChatMessage } from '@/components/chat';

export function useMessages() {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const db = getFirestore(app);
    const messagesRef = collection(db, 'messages');
    const q = query(messagesRef, orderBy('timestamp', 'desc'));

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const newMessages = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          text: data.text,
          isUser: data.isUser,
          timestamp: data.timestamp?.toDate() || new Date(),
        };
      });
      
      setMessages(newMessages);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  return { messages, loading };
}