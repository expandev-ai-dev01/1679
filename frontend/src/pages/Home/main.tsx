export const HomePage = () => {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-4">
      <div className="max-w-2xl w-full space-y-8 text-center">
        <h1 className="text-4xl font-bold text-gray-900">Welcome to AutoClean</h1>
        <p className="text-lg text-gray-600">
          Simple script to identify and remove temporary or duplicate files from a folder.
        </p>
        <div className="mt-8 p-6 bg-white rounded-lg shadow-md">
          <p className="text-gray-700">Get started by implementing the file cleanup features.</p>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
