import axios from "axios";
import { GET_SETTINGS, getSettingsApi } from "@/utils/api/api";
import { useEffect, useState } from "react";
import { useRouter } from "next/router.js";
// import { useEffect } from "react";

// This is settings api
const fetchSettings = async () => {
  try {
    const response = await axios.post(
      `${process.env.NEXT_PUBLIC_API_URL}/${process.env.NEXT_PUBLIC_END_POINT}/${GET_SETTINGS}`
    )

    // console.log('response =>', response)

    const data = response.data
    return data
  } catch (error) {
    console.error('Error fetching data:', error)
    return null
  }
}

export default function Home({ defaultLangCode }) {

  const router = useRouter();

  const [settingsData, setSettingsData] = useState(null);

  // console.log('defaultLangCode =>', defaultLangCode)

  const fetchSettings = async () => {
    try {
        const { data } = await getSettingsApi.getSettings({
            type: '',
        });
        if (!data?.error) {
            setSettingsData({ data: data?.data })
        }
        else {
            console.log("settings error =>", data?.message)
        }

    } catch (error) {
        console.error('Error:', error);
    }
};


useEffect(() => {
  if(process.env.NEXT_PUBLIC_SEO === 'false'){
    fetchSettings()
  }
}, [])

useEffect(() => {
  if(settingsData && process.env.NEXT_PUBLIC_SEO === 'false'){
    router.replace(`/${settingsData?.data?.default_language?.code}`)
  }

  // console.log('settingsData =>', settingsData?.data?.default_language?.code)

}, [settingsData])


  useEffect(() => {
    if(process.env.NEXT_PUBLIC_SEO === 'true'){
    router.replace(`/${defaultLangCode}`)
    }
  }, [])

  return null

}


let serverSidePropsFunction = null
if (process.env.NEXT_PUBLIC_SEO === 'true') {
  serverSidePropsFunction = async context => {
    const { req } = context

    const settingsData = await fetchSettings();
    
    // Add fallback and validation
    let defaultLangCode = settingsData?.data?.default_language?.code;
    
    // For debugging - you can remove this later
    // console.log('defaultLangCode:', defaultLangCode);

    return {
      props: {
        defaultLangCode
      }
    }
  }
}

export const getServerSideProps = serverSidePropsFunction