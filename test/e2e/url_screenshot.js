const puppeteer = require('puppeteer');
const { URL } = require('url');

async function takeUrlScreenshot(targetUrl) {
  let browser;
  try {
    // Validate URL
    if (!targetUrl) {
      throw new Error('URL parameter is required. Usage: node url_screenshot.js <URL>');
    }
    
    // Parse URL to extract hostname for filename
    let parsedUrl;
    try {
      parsedUrl = new URL(targetUrl);
    } catch (error) {
      throw new Error(`Invalid URL: ${targetUrl}`);
    }
    
    // Create filename based on hostname
    const hostname = parsedUrl.hostname.replace(/[^a-zA-Z0-9.-]/g, '_');
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')[0];
    const filename = `screenshot_${hostname}_${timestamp}.png`;
    
    // Launch browser using system Chromium
    browser = await puppeteer.launch({
      headless: true,
      executablePath: '/usr/bin/chromium-browser',
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });
    
    // Create a new page
    const page = await browser.newPage();
    
    // Set viewport size
    await page.setViewport({ width: 1280, height: 800 });
    
    // Navigate to the provided URL
    console.log(`Navigating to ${targetUrl}...`);
    await page.goto(targetUrl, { waitUntil: 'networkidle2' });
    
    // Take screenshot
    console.log('Taking screenshot...');
    await page.screenshot({ 
      path: filename,
      fullPage: true
    });
    
    console.log(`Screenshot saved as ${filename}`);
    
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

// Get URL from command line arguments
const targetUrl = process.argv[2];

if (!targetUrl) {
  console.error('Usage: node url_screenshot.js <URL>');
  console.error('Example: node url_screenshot.js https://daum.net');
  process.exit(1);
}

takeUrlScreenshot(targetUrl);
