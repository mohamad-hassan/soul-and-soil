const fs = require('fs')
const axios = require('axios')
require('dotenv').config();

// Validate essential environment variables
const validateEnvironment = () => {
  const requiredVars = [
    'NEXT_PUBLIC_WEB_URL',
    'NEXT_PUBLIC_API_URL',
    'NEXT_PUBLIC_END_POINT'
  ];

  const missingVars = requiredVars.filter(varName => !process.env[varName]);

  if (missingVars.length > 0) {
    throw new Error(`Missing required environment variables: ${missingVars.join(', ')}`);
  }

  // Validate URL format
  try {
    new URL(process.env.NEXT_PUBLIC_WEB_URL);
    new URL(process.env.NEXT_PUBLIC_API_URL);
  } catch (error) {
    throw new Error(`Invalid URL format in environment variables: ${error.message}`);
  }
}

// Array of static routes that can be easily modified
const staticRoutes = [
  '/',
  '/about-us',
  '/live-news',
  '/all-breaking-news',
  '/video-news',
  '/contact-us',
  '/policy-page/privacy-policy',
  '/policy-page/terms-condition',
  '/rss-feed',
];

// This will be set after fetching settings
let defaultLanguageCode = '';
let defaultLanguageId = '';

const generateUrlEntry = (path) => {
  // Add language code to path, but not for the root path which should remain as just the language code
  const pathWithLang = path ? `${defaultLanguageCode}/${path}?language_id=${defaultLanguageId}` : defaultLanguageCode;
  const url = pathWithLang ? `${process.env.NEXT_PUBLIC_WEB_URL}/${pathWithLang}` : process.env.NEXT_PUBLIC_WEB_URL;
  return `  <url>
    <loc>${url}</loc>
    <lastmod>${new Date().toISOString()}</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>`;
}

const fetchSettings = async () => {
  try {
    const endpoint = `${process.env.NEXT_PUBLIC_API_URL}/${process.env.NEXT_PUBLIC_END_POINT}/get_settings`;
    // console.log(`Fetching settings from: ${endpoint}`);
    const response = await axios.post(endpoint);
    return response.data;
  } catch (error) {
    console.error('Error fetching settings:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
      console.error('Response status:', error.response.status);
    }
    throw new Error(`Failed to fetch settings: ${error.message}`);
  }
}

// Function to fetch dynamic routes from APIs
const fetchDynamicRoutes = async () => {
  try {
    const settings = await fetchSettings();

    // Make sure we have settings data before proceeding
    if (!settings || !settings.data) {
      console.error('Failed to fetch settings or invalid settings data', settings);
      return [];
    }

    // Set global defaultLanguageCode for use in URL generation
    defaultLanguageCode = settings.data?.default_language?.code || settings.code;
    defaultLanguageId = settings.data?.default_language?.id || settings.default_language_id;

    // console.log(`Using language ID: ${defaultLanguageId}, code: ${defaultLanguageCode}`);

    if (!defaultLanguageId || !defaultLanguageCode) {
      console.error('No default language ID or code found in settings');
      return [];
    }

    let allDynamicRoutes = [];

    // Configuration for dynamic routes and their corresponding APIs
    const dynamicRouteConfigs = [
      {
        route: '/categories-news/[id]',
        apiEndpoint: `${process.env.NEXT_PUBLIC_API_URL}/${process.env.NEXT_PUBLIC_END_POINT}/get_category?offet=0&limit=100&language_id=${defaultLanguageId}`,
        pathExtractor: (item) => item.slug?.toString()
      },
      {
        route: '/news/[slug]',
        apiEndpoint: `${process.env.NEXT_PUBLIC_API_URL}/${process.env.NEXT_PUBLIC_END_POINT}/get_news?offet=0&limit=100&language_id=${defaultLanguageId}`,
        pathExtractor: (item) => item.slug
      },
      {
        route: '/breaking-news/[slug]',
        apiEndpoint: `${process.env.NEXT_PUBLIC_API_URL}/${process.env.NEXT_PUBLIC_END_POINT}/get_breaking_news?offet=0&limit=100&language_id=${defaultLanguageId}`,
        pathExtractor: (item) => item.slug
      },
    ];

    // Process each dynamic route configuration
    for (const config of dynamicRouteConfigs) {
      try {
        // console.log(`Fetching data from: ${config.apiEndpoint}`);
        const response = await axios.post(config.apiEndpoint);

        // Extract parameter name from route pattern
        const paramMatch = config.route.match(/\[(.*?)\]/);
        if (!paramMatch) {
          console.warn(`Invalid route pattern: ${config.route}`);
          continue;
        }
        const paramName = paramMatch[1];

        // Map API response to route paths
        if (response.data && Array.isArray(response.data)) {
          const routes = response.data
            .filter(item => config.pathExtractor(item)) // Filter out items without a valid path
            .map(item => {
              const paramValue = config.pathExtractor(item);
              const actualPath = config.route.replace(`[${paramName}]`, paramValue);
              return {
                route: config.route,
                path: actualPath
              };
            });

          allDynamicRoutes = [...allDynamicRoutes, ...routes];
        } else if (response.data && typeof response.data === 'object') {
          // Handle case where API returns object with items array
          const dataArray = response.data.data || response.data.items || [];

          // console.log(`Found ${dataArray.length} items for ${config.route}`);

          if (Array.isArray(dataArray)) {
            const routes = dataArray
              .filter(item => config.pathExtractor(item)) // Filter out items without a valid path
              .map(item => {
                const paramValue = config.pathExtractor(item);
                const actualPath = config.route.replace(`[${paramName}]`, paramValue);
                return {
                  route: config.route,
                  path: actualPath
                };
              });

            allDynamicRoutes = [...allDynamicRoutes, ...routes];
          } else {
            console.warn(`Expected array but got ${typeof dataArray} for ${config.route}`);
          }
        }
      } catch (error) {
        console.error(`Error fetching data for ${config.route}:`, error.message);
        if (error.response) {
          console.error('Response status:', error.response.status);
        }
      }
    }

    console.log(`Total dynamic routes found: ${allDynamicRoutes.length}`);
    return allDynamicRoutes;
  } catch (error) {
    console.error('Error in fetchDynamicRoutes:', error.message);
    return [];
  }
};

const generateSitemap = async () => {
  try {
    // First validate environment variables
    validateEnvironment();

    // First, fetch settings to get the language code
    const settings = await fetchSettings();
    if (!settings || !settings.data) {
      console.error('Failed to fetch settings or invalid settings data');
      return;
    }

    // Set global defaultLanguageCode for use in URL generation
    defaultLanguageCode = settings.data?.default_language?.code || settings.code;
    defaultLanguageId = settings.data?.default_language?.id || settings.default_language_id;

    if (!defaultLanguageCode || !defaultLanguageId) {
      console.error('No default language code or ID found in settings');
      return;
    }

    console.log(`Using language code: ${defaultLanguageCode}, language ID: ${defaultLanguageId} for URLs`);

    // Initialize the sitemap entries array
    let sitemapEntries = [];

    // Add static routes
    staticRoutes.forEach(route => {
      const normalizedRoute = route === '/' ? '' : route.startsWith('/') ? route.slice(1) : route;
      sitemapEntries.push(generateUrlEntry(normalizedRoute));
    });

    // Fetch and add dynamic routes from APIs
    // console.log('Fetching dynamic routes...');
    const dynamicRoutes = await fetchDynamicRoutes();

    if (dynamicRoutes.length === 0) {
      console.warn('No dynamic routes were found or returned from the APIs');
    }

    dynamicRoutes.forEach(({ path }) => {
      const normalizedPath = path.startsWith('/') ? path.slice(1) : path;
      sitemapEntries.push(generateUrlEntry(normalizedPath));
    });

    // console.log(`Added ${dynamicRoutes.length} dynamic routes from API`);

    const sitemap = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${sitemapEntries.join('\n')}
</urlset>`;

    // Make sure the public directory exists
    if (!fs.existsSync('public')) {
      fs.mkdirSync('public', { recursive: true });
    }

    fs.writeFileSync('public/sitemap.xml', sitemap);
    console.log('Sitemap generated successfully with static and dynamic routes!');
  } catch (error) {
    console.error('Error generating sitemap:', error.message);
    process.exit(1);
  }
}

generateSitemap();