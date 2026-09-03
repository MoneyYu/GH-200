package money.gh200.simpleweb;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Build-provenance guard. The compiled {@code application.yml} on the classpath must
 * carry the build SHA that Maven resource filtering embedded at build time, and must
 * never defer that value to a runtime {@code APP_BUILD_SHA} environment variable.
 *
 * <p>Against the unfiltered source this fails, because the build section still holds
 * the runtime placeholder {@code ${APP_BUILD_SHA:dev}}. It passes only once resource
 * filtering replaces the {@code @app.build.sha@} token with the configured value.
 */
class BuildMetadataFilteringTest {

    private static final Pattern SHA_LINE = Pattern.compile("(?m)^\\s*sha:\\s*(\\S+)\\s*$");
    private static final Pattern TIME_LINE = Pattern.compile("(?m)^\\s*time:\\s*(\\S+)\\s*$");

    private String compiledApplicationYml() throws Exception {
        try (InputStream in = getClass().getResourceAsStream("/application.yml")) {
            assertThat(in).as("classpath application.yml").isNotNull();
            return new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
    }

    @Test
    @DisplayName("建置後的 application.yml 內嵌 build 資訊，不再讀取 APP_BUILD_SHA/TIME 執行期環境變數")
    void applicationYmlEmbedsFilteredBuildMetadataInsteadOfRuntimeEnv() throws Exception {
        String yml = compiledApplicationYml();

        assertThat(yml)
                .as("build metadata must be embedded by Maven filtering, not read from the runtime environment")
                .doesNotContain("APP_BUILD_SHA")
                .doesNotContain("APP_BUILD_TIME");

        assertThat(yml)
                .as("Maven resource filtering must have replaced the build metadata tokens")
                .doesNotContain("@app.build.sha@")
                .doesNotContain("@app.build.time@");

        Matcher shaMatcher = SHA_LINE.matcher(yml);
        assertThat(shaMatcher.find()).as("app.build.sha line present").isTrue();
        assertThat(shaMatcher.group(1))
                .as("app.build.sha must be a concrete filtered value")
                .doesNotStartWith("${")
                .doesNotContain("@")
                .isNotBlank();

        Matcher timeMatcher = TIME_LINE.matcher(yml);
        assertThat(timeMatcher.find()).as("app.build.time line present").isTrue();
        assertThat(timeMatcher.group(1))
                .as("app.build.time must be a concrete filtered value")
                .doesNotStartWith("${")
                .doesNotContain("@")
                .isNotBlank();
    }
}
