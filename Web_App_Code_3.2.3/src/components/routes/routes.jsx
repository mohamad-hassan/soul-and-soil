import { currentLangCode, defaultLanguageCode } from "@/utils/helpers";

const currLangCode = currentLangCode();
const defaultLangCode = defaultLanguageCode();

export const publicRoutes = [
  `/${currLangCode ? currLangCode : defaultLangCode}`,
  `/${currLangCode ? currLangCode : defaultLangCode}/all-breaking-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/all-categories`,
  `/${currLangCode ? currLangCode : defaultLangCode}/breaking-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/categories-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/live-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/more-pages`,
  `/${currLangCode ? currLangCode : defaultLangCode}/news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/news-notification`,
  `/${currLangCode ? currLangCode : defaultLangCode}/tag`,
  `/${currLangCode ? currLangCode : defaultLangCode}/video-news-view`,
  `/${currLangCode ? currLangCode : defaultLangCode}/view-al`
]

export const authRoutes = []

export const protectedRoutes = [
  `/${currLangCode ? currLangCode : defaultLangCode}/bookmark`,
  `/${currLangCode ? currLangCode : defaultLangCode}/create-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/edit-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/manage-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/user-based-categories`,
  `/${currLangCode ? currLangCode : defaultLangCode}/personal-notification`,
  `/${currLangCode ? currLangCode : defaultLangCode}/profile-update`,
];

export const manageNewsRoutes = [
  `/${currLangCode ? currLangCode : defaultLangCode}/manage-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/create-news`,
  `/${currLangCode ? currLangCode : defaultLangCode}/edit-news`
];
