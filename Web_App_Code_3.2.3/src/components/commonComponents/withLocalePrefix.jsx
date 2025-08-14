import { defaultLanguageCode } from "@/utils/helpers";
import { useRouter } from "next/router";
import { useEffect } from "react";
import { useSelector } from "react-redux";

/**
 * Higher-Order Component that handles localization route prefix
 * It uses the defaultLang from Redux as the prefix (instead of hardcoded 'en-new')
 * If no locale is in the URL, it uses the defaultLang from Redux
 *
 * @param {React.ComponentType} Component - The component to wrap
 * @returns {React.FC} - The wrapped component with route prefix handling
 */
const withLocalePrefix = (Component) => {
  const WithLocalePrefix = (props) => {
    const router = useRouter();

    const defaultLang = defaultLanguageCode();


    useEffect(() => {
      // Skip if no defaultLang is available
      if (!defaultLang) return;

      // Get the current path
      const currentPath = router.asPath;

      // Check if we're on a path that should have the prefix
      const shouldHavePrefix = !currentPath.includes(`/${defaultLang}`);

      // Check if the path has a locale prefix
      const localeMatch = currentPath.match(/^\/([a-z]{2}(-[a-z]{2})?)\/(.*)$/);
      const isRootPath = currentPath === "/" || currentPath === "";

      if (shouldHavePrefix) {
        // Extract the current locale and path
        let locale = "";
        let path = currentPath;

        if (localeMatch) {
          // Path has a locale prefix
          locale = localeMatch[1];
          path = localeMatch[3] || "";
        } else if (isRootPath) {
          // No locale in URL and we're at root path, use defaultLang
          locale = defaultLang;
          path = "";
        }

        // Only proceed if we have a locale or we're at root
        if (locale || isRootPath) {
          // Construct the new path with the defaultLang prefix
          const newPath = locale
            ? `/${defaultLang}/${path}`
            : `/${defaultLang}${currentPath}`;

          // Replace the current URL without adding to history stack
          router.replace(newPath, undefined, { shallow: true });
        }
      }
    }, []);

    return <Component {...props} />;
  };

  // Copy displayName for better debugging
  WithLocalePrefix.displayName = `WithLocalePrefix(${Component.displayName || Component.name || "Component"
    })`;


  return WithLocalePrefix;
};

export default withLocalePrefix;