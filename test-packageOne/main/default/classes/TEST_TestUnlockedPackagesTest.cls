@isTest
public class TEST_TestUnlockedPackagesTest {
    @isTest
    private static void initializeConstructor(){
        TEST_TestUnlockedPackages obj  = new TEST_TestUnlockedPackages();
		Database.executeBatch(obj, 200);
    }
}