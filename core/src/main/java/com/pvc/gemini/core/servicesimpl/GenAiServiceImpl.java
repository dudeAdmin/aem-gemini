package com.pvc.gemini.core.servicesimpl;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

import javax.jcr.Binary;
import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.Session;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;
import org.apache.sling.api.resource.ResourceResolver;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.metatype.annotations.AttributeDefinition;
import org.osgi.service.metatype.annotations.Designate;
import org.osgi.service.metatype.annotations.ObjectClassDefinition;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.pvc.gemini.core.service.GenAiService;



@Component(service = GenAiService.class)
@Designate(ocd = GenAiServiceImpl.Config.class)
public class GenAiServiceImpl implements GenAiService {


	@ObjectClassDefinition(name = "Google gemini service", description = "Google gemini service to generate assets")
	public static @interface Config {
		@AttributeDefinition(name = "Google Gemini API key", description = "API key for Google Gemini API")
		String geminiApiKey() default "";
	}

	private final Logger logger = LoggerFactory.getLogger(getClass());

	private String geminiApiKey;

	@Activate
	protected void activate(final Config config) {
		geminiApiKey = config.geminiApiKey();
	}

	public static final class ApiParams {
		String prompt;
		String imageFolderPath;
		String outputFormat;
		String aspectRatio;
		String inputImagePath1;
		String inputImagePath2;
		String inputImagePath3;
		String inputImagePath4;

		String inputImage1Base64;
		String inputImage2Base64;
		String inputImage3Base64;
		String inputImage4Base64;
		
		String inputImage1MimeType;
		String inputImage2MimeType;
		String inputImage3MimeType;
		String inputImage4MimeType;

		Node imageFolderNode;
	}

	private ApiParams buildApiParams(SlingHttpServletRequest request) {
		ApiParams params = new ApiParams();
		params.prompt = getParameterValue(request, "prompt");
		params.imageFolderPath = getParameterValue(request, "imageFolderPath");
		params.outputFormat = getParameterValue(request, "outputFormat");
		params.aspectRatio = getParameterValue(request, "aspectRatio");
		params.inputImagePath1 = getParameterValue(request, "inputImagePath1");
		params.inputImagePath2 = getParameterValue(request, "inputImagePath2");
		params.inputImagePath3 = getParameterValue(request, "inputImagePath3");
		params.inputImagePath4 = getParameterValue(request, "inputImagePath4");
		return params;
	}

	private Node getImageNode(Session session, String imagePath) throws RepositoryException {
		if (imagePath != null && !imagePath.isEmpty() && session.nodeExists(imagePath)) {
			return session.getNode(imagePath);
		}
		return null;
	}

	private void updateInputImagesBase64(ApiParams params, Session session) throws  RepositoryException, IOException {
		Node imageFolderNode = getImageNode(session, params.imageFolderPath);
		if (imageFolderNode == null) {
			logger.error("Image folder node not found at path: {}", params.imageFolderPath);
			return;
		}
		params.imageFolderNode = imageFolderNode;
		Node inputImageNode1 = getImageNode(session, params.inputImagePath1);
		Node inputImageNode2 = getImageNode(session, params.inputImagePath2);
		Node inputImageNode3 = getImageNode(session, params.inputImagePath3);
		Node inputImageNode4 = getImageNode(session, params.inputImagePath4);
		
		params.inputImage1Base64 = getBase64Image(inputImageNode1);
        params.inputImage2Base64 = getBase64Image(inputImageNode2);
        params.inputImage3Base64 = getBase64Image(inputImageNode3);
        params.inputImage4Base64 = getBase64Image(inputImageNode4);
        
        params.inputImage1MimeType = getMimeTypeFromNode(inputImageNode1);
        params.inputImage2MimeType = getMimeTypeFromNode(inputImageNode2);
        params.inputImage3MimeType = getMimeTypeFromNode(inputImageNode3);
        params.inputImage4MimeType = getMimeTypeFromNode(inputImageNode4);
        
	}
	
	private String getBase64Image(Node assetNode) throws RepositoryException, IOException {
		if (assetNode == null) {
			return null;
		}

		Node originalJcrContentNode = null;
		if (assetNode.hasNode("jcr:content/renditions/original/jcr:content")) {
			originalJcrContentNode = assetNode.getNode("jcr:content/renditions/original/jcr:content");
		}

		InputStream imageInFile = null;
		if (originalJcrContentNode != null && originalJcrContentNode.hasProperty("jcr:data")) {
			Binary binary = originalJcrContentNode.getProperty("jcr:data").getBinary();
			imageInFile = binary.getStream(); // This is your FileInputStream
		}

		String base64Image = convertToBase64(imageInFile);
		return base64Image != null ? base64Image : "";
	}

	private String convertToBase64(InputStream inputStream) throws IOException {
		if (inputStream == null) {
			return null;
		}
		ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
		byte[] buffer = new byte[8192];
		int bytesRead;

		// Read the InputStream into a byte array
		while ((bytesRead = inputStream.read(buffer)) != -1) {
			outputStream.write(buffer, 0, bytesRead);
		}

		byte[] imageBytes = outputStream.toByteArray();

		// Encode to Base64
		return Base64.getEncoder().encodeToString(imageBytes);
	}
	
	@Override
	public void callGeminiApi(SlingHttpServletRequest request, SlingHttpServletResponse response) {
		ResourceResolver resolver = null;
		Session session = null;
		PrintWriter out = null;
		try {
			JSONObject resp = new JSONObject();
			resolver = request.getResourceResolver();
			session = resolver.adaptTo(Session.class);
			out = response.getWriter();

			ApiParams params = buildApiParams(request);
			updateInputImagesBase64(params, session);
			
			if (params.imageFolderNode == null) {
				resp.put("success", false);
				resp.put("message", "Image folder node not found at path: " + params.imageFolderPath);
				response.setContentType("application/json");
				out.write(resp.toString());
				return;
			}
			
			 String apiResponse = generateImage(params);
			 logger.info("Gemini API response: {}", apiResponse);
	        ImageData imageData = extractImageData(apiResponse);

	        if (imageData != null) {
	            Node imageFolderNode = params.imageFolderNode;
				
	            String fileName = "generated_image_" + System.currentTimeMillis() + getFileExtension(params.outputFormat);
	            saveImageToDAM(imageData, imageFolderNode, fileName, params);

	            resp.put("success", true);
	            resp.put("message", "Image generated and saved successfully");
	            resp.put("path", imageFolderNode.getPath() + "/" + fileName);
	        } else {
	            resp.put("success", false);
	            resp.put("message", "No image data found in API response");
	        }

	        response.setContentType("application/json");
	        out.write(resp.toString());
			

		} catch (Exception e) {
			logger.error("Error occurred in callGeminiApi::", e);
		} finally {
			if (out != null) {
				out.close();
			}
			if (resolver != null && resolver.isLive()) {
				resolver.close();
			}
			if (session != null && session.isLive()) {
				session.logout();
			}
		}
	}
	
	private String getFileExtension(String mimeType) {
        switch (mimeType) {
            case "image/jpeg":
                return ".jpg";
            case "image/png":
                return ".png";
            case "image/gif":
                return ".gif";
            case "image/bmp":
                return ".bmp";
            }
        return ".jpg"; // Default extension
	}
	
	private void saveImageToDAM(ImageData imageData, Node imageFolderNode, String fileName, ApiParams params) throws RepositoryException {
	    if (imageData == null || imageFolderNode == null) {
	        logger.error("ImageData or imageFolderNode is null");
	        return;
	    }

	    // Decode Base64 to byte array
	    byte[] imageBytes = Base64.getDecoder().decode(imageData.base64Data);

	    // Create asset node
	    Node assetNode = imageFolderNode.addNode(fileName, "dam:Asset");
	    Node jcrContentNode = assetNode.addNode("jcr:content", "dam:AssetContent");
	    jcrContentNode.setProperty("jcr:title", fileName);

	    // Create metadata node
	    Node metadataNode = jcrContentNode.addNode("metadata", "nt:unstructured");
	    metadataNode.setProperty("dc:format", params.outputFormat);

	    // Create renditions node
	    Node renditionsNode = jcrContentNode.addNode("renditions", "nt:folder");
	    Node originalNode = renditionsNode.addNode("original", "nt:file");
	    Node originalJcrContent = originalNode.addNode("jcr:content", "nt:resource");

	    // Set properties for the original rendition
	    originalJcrContent.setProperty("jcr:mimeType", params.outputFormat);
	    originalJcrContent.setProperty("jcr:lastModified", java.util.Calendar.getInstance());

	    // Create binary from byte array
	    Binary binary = imageFolderNode.getSession().getValueFactory().createBinary(
	        new java.io.ByteArrayInputStream(imageBytes)
	    );
	    originalJcrContent.setProperty("jcr:data", binary);

	    // Save the session
	    imageFolderNode.getSession().save();

	    logger.info("Image saved successfully to DAM at: {}", assetNode.getPath());
	}
	
	private String generateImage(ApiParams params) throws IOException, JSONException {
		String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key="
				+ geminiApiKey;

		// Build request body
		JSONObject requestBody = new JSONObject();
		JSONArray contents = new JSONArray();
		JSONObject content = new JSONObject();
		JSONArray parts = new JSONArray();

		// Add text prompt
		JSONObject textPart = new JSONObject();
		textPart.put("text", params.prompt);
		parts.put(textPart);

		// Add images
		if (params.inputImage1Base64 != null && !params.inputImage1Base64.isEmpty()) {
	        JSONObject imagePart = new JSONObject();
	        JSONObject inlineData = new JSONObject();
	        inlineData.put("mime_type", params.inputImage1MimeType != null ? params.inputImage1MimeType : "image/png");
	        inlineData.put("data", params.inputImage1Base64);
	        imagePart.put("inline_data", inlineData);
	        parts.put(imagePart);
	    }

	    if (params.inputImage2Base64 != null && !params.inputImage2Base64.isEmpty()) {
	        JSONObject imagePart = new JSONObject();
	        JSONObject inlineData = new JSONObject();
	        inlineData.put("mime_type", params.inputImage2MimeType != null ? params.inputImage2MimeType : "image/png");
	        inlineData.put("data", params.inputImage2Base64);
	        imagePart.put("inline_data", inlineData);
	        parts.put(imagePart);
	    }

	    if (params.inputImage3Base64 != null && !params.inputImage3Base64.isEmpty()) {
	        JSONObject imagePart = new JSONObject();
	        JSONObject inlineData = new JSONObject();
	        inlineData.put("mime_type", params.inputImage3MimeType != null ? params.inputImage3MimeType : "image/png");
	        inlineData.put("data", params.inputImage3Base64);
	        imagePart.put("inline_data", inlineData);
	        parts.put(imagePart);
	    }

	    if (params.inputImage4Base64 != null && !params.inputImage4Base64.isEmpty()) {
	        JSONObject imagePart = new JSONObject();
	        JSONObject inlineData = new JSONObject();
	        inlineData.put("mime_type", params.inputImage4MimeType != null ? params.inputImage4MimeType : "image/png");
	        inlineData.put("data", params.inputImage4Base64);
	        imagePart.put("inline_data", inlineData);
	        parts.put(imagePart);
	    }

		content.put("parts", parts);
		contents.put(content);
		requestBody.put("contents", contents);
		
		logger.info("Request Body for Gemini API: {}", requestBody.toString());

		// Add generation config
		JSONObject generationConfig = new JSONObject();
		JSONArray responseModalities = new JSONArray();
		responseModalities.put("Image");
		generationConfig.put("responseModalities", responseModalities);

		JSONObject imageConfig = new JSONObject();
		imageConfig.put("aspectRatio",
				params.aspectRatio != null && !params.aspectRatio.isEmpty() ? params.aspectRatio : "16:9");
		generationConfig.put("imageConfig", imageConfig);

		requestBody.put("generationConfig", generationConfig);

		// Make HTTP POST request
		URL url = new URL(apiUrl);
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.setRequestMethod("POST");
		connection.setRequestProperty("Content-Type", "application/json");
		connection.setDoOutput(true);

		// Send request
		try (PrintWriter writer = new PrintWriter(connection.getOutputStream())) {
			writer.write(requestBody.toString());
			writer.flush();
		}

		// Read response
		int responseCode = connection.getResponseCode();
		StringBuilder responseBody = new StringBuilder();

		try (BufferedReader reader = new BufferedReader(new InputStreamReader(
				responseCode >= 400 ? connection.getErrorStream() : connection.getInputStream()))) {
			String line;
			while ((line = reader.readLine()) != null) {
				responseBody.append(line);
			}
		}

		connection.disconnect();

		if (responseCode >= 400) {
			logger.error("Error from Gemini API: {}", responseBody.toString());
			throw new IOException("API request failed with status code: " + responseCode);
		}

		return responseBody.toString();
	}
	
	private static class ImageData {
		public String mimeType;
		public String base64Data;

		public ImageData(String mimeType, String base64Data) {
			this.mimeType = mimeType;
			this.base64Data = base64Data;
		}
	}
	
	private ImageData extractImageData(String jsonResponse) throws JSONException {
		JSONObject root = new JSONObject(jsonResponse);
		JSONArray candidates = root.optJSONArray("candidates");

		if (candidates != null && candidates.length() > 0) {
			JSONObject candidate = candidates.getJSONObject(0);
			JSONObject content = candidate.optJSONObject("content");
			JSONArray parts = content.optJSONArray("parts");

			if (parts != null) {
				for (int i = 0; i < parts.length(); i++) {
					JSONObject part = parts.getJSONObject(i);
					if (part.has("inlineData")) {
						JSONObject inlineData = part.getJSONObject("inlineData");
						String mimeType = inlineData.optString("mimeType", null);
						String base64Data = inlineData.optString("data", null);

						if (mimeType != null && base64Data != null) {
							return new ImageData(mimeType, base64Data);
						}
					}
				}
			}
		}

		return null; // No valid image data found
	}

	private String getParameterValue(SlingHttpServletRequest request, String paramName) {
		String paramValue = request.getParameter(paramName);
		return paramValue != null ? paramValue : "";
	}
	
	public String getMimeTypeFromNode(Node assetNode) throws RepositoryException {
		if (assetNode == null) {
			return "";
		}
		if (assetNode.hasNode("jcr:content/metadata")) {
			Node metadataNode = assetNode.getNode("jcr:content/metadata");
			if (metadataNode.hasProperty("dam:MIMEtype")) {
				return metadataNode.getProperty("dam:MIMEtype").getString();
			}
		}
		return "";
	}

}
