import { clsx } from 'clsx';
import type { LoadingSpinnerProps } from './types';

export const LoadingSpinner = ({ size = 'md', className }: LoadingSpinnerProps) => {
  return (
    <div className={clsx('flex items-center justify-center', className)}>
      <div
        className={clsx('animate-spin rounded-full border-b-2 border-blue-600', {
          'h-4 w-4': size === 'sm',
          'h-8 w-8': size === 'md',
          'h-12 w-12': size === 'lg',
        })}
      />
    </div>
  );
};
