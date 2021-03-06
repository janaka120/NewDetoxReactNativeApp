describe('Example', () => {
  beforeAll(async () => {
    await device.launchApp({newInstance: true});
  });

  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should have edit text on welcome screen', async () => {
    await expect(element(by.id('edit-text'))).toBeVisible();
  });
});
