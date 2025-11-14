# AutoClean Backend

## Description
Backend API for AutoClean - A file management system that identifies and removes temporary or duplicate files from selected folders.

## Features
- Identify and remove temporary files
- RESTful API architecture
- Multi-tenancy support
- Secure authentication and authorization
- Comprehensive error handling

## Technology Stack
- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MS SQL Server
- **Validation**: Zod

## Prerequisites
- Node.js 18.x or higher
- MS SQL Server
- npm or yarn

## Installation

1. Clone the repository
```bash
git clone <repository-url>
cd autoclean-backend
```

2. Install dependencies
```bash
npm install
```

3. Configure environment variables
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Run database migrations
```bash
# Execute SQL scripts in database/ folder
```

## Development

### Start development server
```bash
npm run dev
```

### Build for production
```bash
npm run build
```

### Start production server
```bash
npm start
```

### Run tests
```bash
npm test
```

### Lint code
```bash
npm run lint
npm run lint:fix
```

## Project Structure

```
src/
├── api/                 # API controllers
│   └── v1/             # API version 1
│       ├── external/   # Public endpoints
│       └── internal/   # Authenticated endpoints
├── routes/             # Route definitions
├── middleware/         # Express middleware
├── services/           # Business logic
├── utils/              # Utility functions
├── constants/          # Application constants
├── instances/          # Service instances
├── tests/              # Global test utilities
├── config/             # Configuration
└── server.ts           # Application entry point
```

## API Documentation

### Base URL
- Development: `http://localhost:3000/api/v1`
- Production: `https://api.yourdomain.com/api/v1`

### Health Check
```
GET /health
```

### API Endpoints
Endpoints will be documented as features are implemented.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|----------|
| NODE_ENV | Environment mode | development |
| PORT | Server port | 3000 |
| DB_SERVER | Database server | localhost |
| DB_PORT | Database port | 1433 |
| DB_USER | Database user | sa |
| DB_PASSWORD | Database password | - |
| DB_NAME | Database name | autoclean |

## Contributing

1. Create a feature branch
2. Make your changes
3. Write/update tests
4. Submit a pull request

## License
ISC

## Support
For issues and questions, please open an issue in the repository.