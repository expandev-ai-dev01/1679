# AutoClean Backend

Backend API for AutoClean - File management system for identifying and removing temporary files.

## Project Overview

AutoClean is a simple script that identifies and removes temporary or duplicate files from a selected folder, helping to free up disk space.

## Technology Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: Microsoft SQL Server
- **Validation**: Zod

## Project Structure

```
src/
├── api/                    # API Controllers
│   └── v1/                 # API Version 1
│       ├── external/       # Public endpoints
│       └── internal/       # Authenticated endpoints
├── routes/                 # Route definitions
│   └── v1/                 # Version 1 routes
├── middleware/             # Express middleware
├── services/               # Business logic services
├── utils/                  # Utility functions
├── constants/              # Application constants
├── instances/              # Service instances
├── config/                 # Configuration
└── server.ts               # Application entry point
```

## Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Microsoft SQL Server

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy `.env.example` to `.env` and configure your environment variables:
   ```bash
   cp .env.example .env
   ```

4. Configure database connection in `.env`

### Development

Run the development server:
```bash
npm run dev
```

The server will start on `http://localhost:3000` (or the port specified in `.env`).

### Building for Production

Build the project:
```bash
npm run build
```

Start the production server:
```bash
npm start
```

## API Documentation

### Base URL

- Development: `http://localhost:3000/api/v1`
- Production: `https://api.yourdomain.com/api/v1`

### Health Check

```
GET /health
```

Returns the health status of the API.

## Database

The database layer follows a schema-based architecture:

- **config**: System-wide configuration
- **functional**: Business logic and entities
- **security**: Authentication and authorization
- **subscription**: Account management

Database scripts should be placed in the `database/` directory following the established structure.

## Code Standards

- Follow TypeScript strict mode
- Use ESLint for code quality
- Write comprehensive tests
- Document all public APIs with TSDoc comments
- Follow the established naming conventions

## Testing

Run tests:
```bash
npm test
```

Run tests in watch mode:
```bash
npm run test:watch
```

## Linting

Run ESLint:
```bash
npm run lint
```

Fix linting issues:
```bash
npm run lint:fix
```

## Environment Variables

See `.env.example` for all available environment variables and their descriptions.

## Contributing

1. Create a feature branch
2. Make your changes
3. Write tests
4. Submit a pull request

## License

ISC