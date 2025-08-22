const puppeteer = require('puppeteer');

async function takeNaverScreenshot() {
  let browser;
  try {
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
    
    // Navigate to Naver
    console.log('Navigating to https://naver.com...');
    await page.goto('https://naver.com', { waitUntil: 'networkidle2' });
    
    // Take screenshot
    console.log('Taking screenshot...');
    await page.screenshot({ 
      path: 'naver_screenshot.png',
      fullPage: true
    });
    
    console.log('Screenshot saved as naver_screenshot.png');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

takeNaverScreenshot();
