export enum NodeEnv {
  local = 'local',
  development = 'development',
  production = 'production',
}

export const Env = {
  // Environment Variables
  environment: process.env.NODE_ENV,

  // Prisma MongoDB Production
  databaseUrl: process.env.DATABASE_URL,

};
