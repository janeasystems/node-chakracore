package nodejsmobile.test.testnode;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.content.res.AssetManager;
import java.io.*;
import java.lang.System;

public class MainActivity extends Activity {

    private static AssetManager assetManager = null;
    private static String TAG = "TestNode";

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
        System.loadLibrary("node");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Get the args for node
        String nodeArgs = getIntent().getStringExtra("nodeargs");

        if (nodeArgs == null) {
            // Note: use Log.v to keep the app logging diversified from
            // the node logging that uses Log.i and Log.e
            Log.v(TAG, "No input args, copying assets...");
            this.assetManager = this.getAssets();
            try {
                copyTestAssets();
            } catch (IOException e) {
                e.printStackTrace();
                Log.v(TAG, "COPYASSETS:FAIL");
                return;
            }
            Log.v(TAG, "COPYASSETS:PASS");
            return;
        }
        String nodeSubstituteDir=getIntent().getStringExtra("substitutedir");

        if (nodeArgs.startsWith("-p")) {
            RunNode("node " + nodeArgs);
        } else {
            final String testFolderPath = this.getBaseContext().getFilesDir().getAbsolutePath() + "/test/";
            final String mainjsPath = testFolderPath + "main-test.js";
            String[] parts = nodeArgs.split(" ");
            String newArgs = "";
            // Node input flags go before main-test.js
            for (int i = 0; i < ( parts.length ); i++) {
                if (nodeSubstituteDir == null) {
                    newArgs += parts[i] + " ";
                } else {
                    //if there is a dir to substitute in the node arguments, do it.
                    newArgs += parts[i].replace(nodeSubstituteDir,testFolderPath) + " ";
                }
            }
            // Last arg is the test filename
            newArgs = "node -r " + mainjsPath + " " + newArgs;
            RunNode(newArgs);
        }
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native Integer startNodeWithArguments(String[] arguments, String nodePath, boolean redirectOutputToLogcat);

    private void RunNode(String args) {
        Log.v(TAG, "Args: " + args);

        final String testFolderPath = this.getBaseContext().getFilesDir().getAbsolutePath();
        final String[] parts = args.split(" ");

        Thread mainNodeThread = new Thread(new Runnable() {
            @Override
            public void run() {
                startNodeWithArguments(
                        parts,
                        testFolderPath,
                        true);
            }
        });
        mainNodeThread.setUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler() {
            //If the node thread throws some exception, let's say the test fails.
            public void uncaughtException(Thread t, Throwable e) {
                Log.i(TAG, "RESULT:FAIL");
            }
        });
        mainNodeThread.start();
    }

    private void copyTestAssets() throws IOException {
        String destFolder = this.getBaseContext().getFilesDir().getAbsolutePath() + "/test";
        File folderObject = new File(destFolder);
        if (folderObject.exists()) {
            deleteFolderRecursively(folderObject);
        }
        enumerateAssetFolder("", destFolder);
    }

    private void enumerateAssetFolder(String srcFolder, String destPath) throws IOException {
        String[] files = assetManager.list(srcFolder);

        if (files.length == 0) {
            copyAssetFile(srcFolder, destPath);
        } else {
            new File(destPath).mkdirs();
            for (String file : files) {
                if (srcFolder.equals("")) {
                    enumerateAssetFolder(file, destPath + "/" + file);
                } else {
                    enumerateAssetFolder(srcFolder + "/" + file, destPath + "/" + file);
                }
            }
        }
    }

    private void copyAssetFile(String srcFolder, String destPath) throws IOException {
        InputStream in = assetManager.open(srcFolder);
        new File(destPath).createNewFile();
        OutputStream out = new FileOutputStream(destPath);
        copyFile(in, out);
        in.close();
        in = null;
        out.flush();
        out.close();
        out = null;
    }

    private void copyFile(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[1024];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }
    }

    private void deleteFolderRecursively(File file) throws IOException {
        for (File childFile : file.listFiles()) {
            if (childFile.isDirectory()) {
                deleteFolderRecursively(childFile);
            } else {
                childFile.delete();
            }
        }
        file.delete();
    }
}
