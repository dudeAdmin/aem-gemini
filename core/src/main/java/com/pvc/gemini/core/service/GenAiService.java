package com.pvc.gemini.core.service;

import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.SlingHttpServletResponse;

public interface GenAiService {
	
	public void callGeminiApi(SlingHttpServletRequest request, SlingHttpServletResponse response);

}