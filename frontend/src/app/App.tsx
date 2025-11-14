import { QueryClientProvider } from '@tanstack/react-query';
import { AppRouter } from '@/app/router';
import { queryClient } from '@/core/lib/queryClient';

export const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <AppRouter />
    </QueryClientProvider>
  );
};
