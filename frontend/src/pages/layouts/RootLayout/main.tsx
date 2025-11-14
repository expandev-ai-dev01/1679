import { Outlet } from 'react-router-dom';
import { ErrorBoundary } from '@/core/components/ErrorBoundary';

export const RootLayout = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      <ErrorBoundary>
        <Outlet />
      </ErrorBoundary>
    </div>
  );
};
