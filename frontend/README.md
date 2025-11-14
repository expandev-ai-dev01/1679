# AutoClean Frontend

Simple script to identify and remove temporary or duplicate files from a folder.

## Tech Stack

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router 7.9.3
- TanStack Query 5.90.2
- Axios 1.12.2
- Zustand 5.0.8

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
npm install
```

### Environment Setup

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

### Development

```bash
npm run dev
```

### Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
src/
├── app/                 # Application configuration
│   ├── App.tsx
│   ├── router.tsx
│   └── providers.tsx
├── pages/              # Page components
│   ├── Home/
│   ├── NotFound/
│   └── layouts/
├── domain/             # Business domains
├── core/               # Shared components and utilities
│   ├── components/
│   ├── lib/
│   └── utils/
└── assets/            # Static assets
    └── styles/
```

## Features

- Identify and remove temporary files
- Detect common temporary file extensions (.tmp, .temp, .cache)
- Clean up system temporary file patterns
- Free up disk space

## License

MIT