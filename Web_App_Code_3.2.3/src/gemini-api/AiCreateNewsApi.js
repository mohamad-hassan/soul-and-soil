/**
 * AI Service Module using Google Gemini API
 * This module contains all AI-related API calls for the application
 */

// Gemini API configuration
const GEMINI_API_KEY = process.env.NEXT_PUBLIC_GEMINI_API_KEY;
const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models";
const GEMINI_MODEL = "gemini-2.0-flash"; // You can also use gemini-1.5-pro for more advanced use cases

/**
 * Helper function to make Gemini API calls
 * @param {string} prompt - The prompt text to send to Gemini
 * @param {string} systemInstruction - Optional system instruction
 * @returns {Promise<Object>} - Gemini API response
 */
const callGeminiAPI = async (prompt, systemInstruction = null) => {
    try {
        const requestBody = {
            contents: [
                {
                    parts: [{ text: prompt }]
                }
            ]
        };

        // Add system instruction if provided
        if (systemInstruction) {
            requestBody.systemInstruction = { parts: [{ text: systemInstruction }] };
        }

        const response = await fetch(
            `${GEMINI_API_URL}/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(requestBody)
            }
        );

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error?.message || 'Failed to generate content');
        }

        return await response.json();
    } catch (error) {
        console.error('Gemini API error:', error);
        throw error;
    }
};

/**
 * Generate content using AI based on a prompt and context
 * @param {Object} params - Parameters for content generation
 * @param {string} params.prompt - User's prompt for content generation
 * @param {string} params.title - Title of the news article (optional)
 * @param {string} params.category - Category of the news article (optional)
 * @param {string} params.language - Language name (e.g., "English", "Spanish")
 * @param {string} params.languageCode - Language code (e.g., "en", "es")
 * @returns {Promise<Object>} - Generated content
 */
export const generateContent = async ({ prompt, title, category, language, languageCode }) => {
    try {
        // Build the prompt with available context
        let fullPrompt = 'You are a skilled news article writer. Create engaging and informative content.';

        if (title) {
            fullPrompt += `\n\nWrite an article with the title: "${title}"`;
        }

        if (category) {
            fullPrompt += `\nCategory: ${category}`;
        }

        if (language && languageCode) {
            fullPrompt += `\n\nIMPORTANT: Generate all content in ${language} language (${languageCode}). The response MUST be in ${language}.`;
        }

        fullPrompt += `\n\nRequest: ${prompt}\n\nArticle:`;

        console.log("Generating content:", prompt.substring(0, 50) + "...", language ? `in ${language}` : "");
        const response = await callGeminiAPI(fullPrompt);

        // Extract the generated text from Gemini response
        const content = response.candidates[0].content.parts[0].text;

        return {
            content: content
        };
    } catch (error) {
        console.error('AI content generation error:', error);
        throw error;
    }
};

/**
 * Generate meta information using AI based on a title
 * @param {Object} params - Parameters for meta generation
 * @param {string} params.title - Title of the news article
 * @param {string} params.language - Language name (e.g., "English", "Spanish")
 * @param {string} params.languageCode - Language code (e.g., "en", "es")
 * @returns {Promise<Object>} - Generated meta information (title, description, keywords)
 */
export const generateMetaInfo = async ({ title, language, languageCode }) => {
    try {
        let languageInstruction = "";
        if (language && languageCode) {
            languageInstruction = `\n\nIMPORTANT: Generate all content in ${language} language (${languageCode}). The response MUST be in the same language as the title.`;
        }

        const prompt = `You are an SEO expert. Generate meta title, description, keywords, and a slug for this news article titled: "${title}".${languageInstruction}
    
Return ONLY a JSON object with these fields:
- meta_title: an SEO-friendly title (max 60 chars)
- meta_description: an engaging description (between 50-160 chars)
- meta_keywords: comma-separated keywords
- slug: URL-friendly version of the title

The response must be valid JSON format with these exact field names. Do not include any explanation or additional text.`;

        console.log("Generating meta info for:", title, language ? `in ${language}` : "");
        const response = await callGeminiAPI(prompt);
        const responseText = response.candidates[0].content.parts[0].text.trim();
        console.log("Raw meta info response:", responseText);

        // Handle potential JSON parsing issues
        try {
            // Try to directly parse if response is valid JSON
            return JSON.parse(responseText);
        } catch (parseError) {
            console.error("JSON parse error:", parseError.message);
            console.log("Attempting alternative parsing methods...");

            // If direct parsing fails, extract JSON-like content using regex
            const jsonMatch = responseText.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                try {
                    const extractedJson = jsonMatch[0];
                    console.log("Extracted JSON-like content:", extractedJson);
                    return JSON.parse(extractedJson);
                } catch (secondParseError) {
                    console.error("Second JSON parse error:", secondParseError.message);
                }
            }

            // Fallback to basic structure if parsing fails
            console.log("Using fallback values for meta info");
            return {
                meta_title: title,
                meta_description: `Read about ${title} in our latest news article.`,
                meta_keywords: title.toLowerCase().split(' ').join(','),
                slug: title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
            };
        }
    } catch (error) {
        console.error('AI meta generation error:', error);
        throw error;
    }
};

/**
 * Suggest tags using AI based on the title and content
 * @param {Object} params - Parameters for tag suggestion
 * @param {string} params.title - Title of the news article
 * @param {string} params.content - Content of the news article (optional)
 * @param {string} params.category - Category of the news article (optional)
 * @returns {Promise<Object>} - Suggested tags
 */
export const suggestTags = async ({ title, content, category }) => {
    try {
        let prompt = `You are a content tagging expert. Suggest relevant tags for a news article with the title: "${title}"`;

        if (category) {
            prompt += `\nCategory: ${category}`;
        }

        if (content) {
            const contentPreview = content.substring(0, 500) + (content.length > 500 ? "..." : "");
            prompt += `\nContent preview: ${contentPreview}`;
        }

        prompt += "\nReturn ONLY a JSON array of tag names, with no additional text or explanation.";

        const response = await callGeminiAPI(prompt);
        const responseText = response.candidates[0].content.parts[0].text.trim();

        // Handle potential JSON parsing issues
        try {
            // Try to extract array if proper JSON array
            if (responseText.trim().startsWith('[') && responseText.trim().endsWith(']')) {
                return { tags: JSON.parse(responseText) };
            }

            // Try to extract JSON array from text
            const arrayMatch = responseText.match(/\[[\s\S]*\]/);
            if (arrayMatch) {
                return { tags: JSON.parse(arrayMatch[0]) };
            }

            // If all else fails, split by commas or newlines
            const fallbackTags = responseText
                .replace(/["'\[\]{}]/g, '')
                .split(/[,\n]/)
                .map(tag => tag.trim())
                .filter(tag => tag.length > 0);

            return { tags: fallbackTags };
        } catch (parseError) {
            console.error('Error parsing tags response:', parseError);
            // Fallback to simple splitting
            const fallbackTags = responseText
                .split(/[,\n]/)
                .map(tag => tag.trim())
                .filter(tag => tag.length > 0 && !tag.includes(':'));

            return { tags: fallbackTags };
        }
    } catch (error) {
        console.error('AI tag suggestion error:', error);
        throw error;
    }
};

/**
 * Generate an image using AI based on a prompt
 * @param {Object} params - Parameters for image generation
 * @param {string} params.prompt - Description of the image to generate
 * @param {string} params.title - Title of the news article (optional for context)
 * @returns {Promise<Blob>} - Generated image as a Blob
 */
export const generateImage = async ({ prompt, title }) => {
    try {
        // Note: Gemini doesn't have direct image generation like DALL-E
        // We'll use a fallback service or external API for image generation

        // Option 1: Use a different image generation API (e.g., Stable Diffusion or similar)
        // This is just a placeholder - you'll need to implement an actual image generation API call

        // For now, let's redirect to a placeholder image service with the prompt as text
        let fullPrompt = prompt;
        if (title) {
            fullPrompt = `${prompt} for news article titled "${title}"`;
        }

        // Using DummyImage as a fallback (this won't generate AI images, just a placeholder)
        // In production, replace with an actual image generation API
        const encodedPrompt = encodeURIComponent(fullPrompt.substring(0, 50));
        const placeholderUrl = `https://via.placeholder.com/1024x1024.png?text=${encodedPrompt}`;

        console.warn('Note: Gemini does not support image generation. Using placeholder image instead.');
        console.warn('Consider integrating a dedicated image generation API like Stable Diffusion.');

        // Fetch the placeholder image and convert to blob
        const imageResponse = await fetch(placeholderUrl);
        return await imageResponse.blob();
    } catch (error) {
        console.error('AI image generation error:', error);
        throw error;
    }
};

export default {
    generateContent,
    generateMetaInfo,
    suggestTags,
    generateImage,
}; 